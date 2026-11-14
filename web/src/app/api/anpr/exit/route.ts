import { NextResponse } from "next/server";
import { revalidatePath } from "next/cache";
import { dbErrorMessage, withTransaction } from "@/lib/db";
import { getFareQuote } from "@/lib/fare";
import { findBestActiveTicketMatch, cleanPlateString } from "@/lib/anpr";

type ActiveTicketRow = {
  ticket_no: number;
  slot_id: number;
  slot_no: string;
  zone_name: string;
  vehicle_id: number;
  registration_no: string;
  entry_time: string;
};

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const rawReg = body.registration_no?.toString().trim().toUpperCase() ?? "";
    const requestedTicketNo = body.ticket_no ? Number(body.ticket_no) : null;
    const gateId = body.exit_gate_id ? Number(body.exit_gate_id) : null;
    const paymentMode = (body.payment_mode || "CASH").toString().toUpperCase();

    if (!rawReg && !requestedTicketNo) {
      return NextResponse.json(
        { success: false, error: "Registration number or ticket number is required." },
        { status: 400 }
      );
    }
    if (!gateId) {
      return NextResponse.json(
        { success: false, error: "Exit gate ID is required." },
        { status: 400 }
      );
    }

    const result = await withTransaction(async (client) => {
      // 1. Validate that the exit gate exists and is active
      const gateRes = await client.query(
        "SELECT gate_id, gate_number, zone_id FROM parking_gate WHERE gate_id = $1 AND status = 'ACTIVE' AND gate_type = 'EXIT'",
        [gateId]
      );
      if (gateRes.rows.length === 0) {
        throw new Error("Specified exit gate is invalid or inactive.");
      }
      const gate = gateRes.rows[0];

      let targetTicket: ActiveTicketRow | null = null;
      let matchType: "EXACT" | "FUZZY" | "DIRECT" = "DIRECT";
      let matchConfidence = 100;
      let topSuggestions: { ticket_no: number; registration_no: string; slot_no: string; similarity: number }[] = [];

      // 2. If ticket_no is explicitly provided (operator manual click / confirmation)
      if (requestedTicketNo) {
        const ticketRes = await client.query<ActiveTicketRow>(
          `SELECT t.ticket_no, t.slot_id, s.slot_no, z.zone_name, v.vehicle_id, v.registration_no,
                  to_char(t.entry_time, 'YYYY-MM-DD HH24:MI:SS') as entry_time
             FROM parking_ticket t
             JOIN vehicle v ON v.vehicle_id = t.vehicle_id
             JOIN parking_slot s ON s.slot_id = t.slot_id
             JOIN parking_zone z ON z.zone_id = s.zone_id
            WHERE t.ticket_no = $1 AND t.ticket_status = 'ACTIVE'
            FOR UPDATE`,
          [requestedTicketNo]
        );
        targetTicket = ticketRes.rows[0] ?? null;
      } else {
        // 3. Otherwise: Intelligent Lookup across all currently ACTIVE tickets in the parking lot
        const activeTicketsRes = await client.query<ActiveTicketRow>(
          `SELECT t.ticket_no, t.slot_id, s.slot_no, z.zone_name, v.vehicle_id, v.registration_no,
                  to_char(t.entry_time, 'YYYY-MM-DD HH24:MI:SS') as entry_time
             FROM parking_ticket t
             JOIN vehicle v ON v.vehicle_id = t.vehicle_id
             JOIN parking_slot s ON s.slot_id = t.slot_id
             JOIN parking_zone z ON z.zone_id = s.zone_id
            WHERE t.ticket_status = 'ACTIVE'
            FOR UPDATE`
        );

        const activeTickets = activeTicketsRes.rows;
        const matchResult = findBestActiveTicketMatch(rawReg, activeTickets, 0.70);

        topSuggestions = matchResult.candidates.map((c) => ({
          ticket_no: c.ticket_no,
          registration_no: c.registration_no,
          slot_no: c.slot_no,
          similarity: Math.round(c.similarity * 100),
        }));

        if (matchResult.match) {
          targetTicket = matchResult.match;
          matchType = matchResult.matchType as "EXACT" | "FUZZY";
          matchConfidence = Math.round(matchResult.similarity * 100);
        }
      }

      if (!targetTicket) {
        return {
          notFound: true,
          scannedReg: rawReg,
          suggestions: topSuggestions,
        };
      }

      const ticketNo = targetTicket.ticket_no;

      // 4. Calculate fare quote
      const quote = await getFareQuote(client, ticketNo);
      const totalHours = quote ? quote.total_hours : 1;
      const totalAmount = quote ? quote.amount : 50;

      // 5. Insert into parking_exit
      const exitRes = await client.query(
        `INSERT INTO parking_exit (ticket_no, exit_time, exit_gate_id, total_hours, total_amount)
         VALUES ($1, LOCALTIMESTAMP(0), $2, $3, $4)
         RETURNING exit_id, to_char(exit_time, 'YYYY-MM-DD HH24:MI:SS') as exit_time`,
        [ticketNo, gateId, totalHours, totalAmount]
      );
      const exitId = exitRes.rows[0].exit_id;
      const exitTime = exitRes.rows[0].exit_time;

      // 6. Record payment in payment_details
      await client.query(
        `INSERT INTO payment_details (exit_id, payment_mode, payment_status, amount_paid)
         VALUES ($1, $2, 'SUCCESSFUL', $3)`,
        [exitId, paymentMode, totalAmount]
      );

      // 7. Update ticket status to COMPLETED
      await client.query(
        "UPDATE parking_ticket SET ticket_status = 'COMPLETED' WHERE ticket_no = $1",
        [ticketNo]
      );

      // 8. CRUCIAL: Empty the slot (UPDATE availability_status = 'AVAILABLE')
      await client.query(
        "UPDATE parking_slot SET availability_status = 'AVAILABLE' WHERE slot_id = $1",
        [targetTicket.slot_id]
      );

      return {
        success: true,
        ticketNo,
        slotId: targetTicket.slot_id,
        slotNo: targetTicket.slot_no,
        zoneName: targetTicket.zone_name,
        entryTime: targetTicket.entry_time,
        exitTime,
        gateNumber: gate.gate_number,
        registrationNo: targetTicket.registration_no,
        scannedReg: rawReg,
        matchType,
        matchConfidence,
        totalHours,
        totalAmount,
        paymentMode,
      };
    });

    if (result.notFound) {
      return NextResponse.json(
        {
          success: false,
          status: "NOT_PARKED",
          message: `Vehicle ${result.scannedReg} not found in active parking tickets.`,
          scannedReg: result.scannedReg,
          suggestions: result.suggestions,
        },
        { status: 404 }
      );
    }

    revalidatePath("/", "layout");

    const matchNotice =
      result.matchType === "FUZZY"
        ? ` (Matched active vehicle ${result.registrationNo} with ${result.matchConfidence}% confidence)`
        : "";

    return NextResponse.json({
      success: true,
      status: "EXITED",
      message: `Vehicle ${result.registrationNo}${matchNotice} exited! Slot ${result.slotNo} (${result.zoneName}) is now EMPTY (AVAILABLE). Fee: ₹${result.totalAmount}.`,
      data: result,
    });
  } catch (err) {
    return NextResponse.json(
      { success: false, error: dbErrorMessage(err) },
      { status: 500 }
    );
  }
}

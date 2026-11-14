import { NextResponse } from "next/server";
import { revalidatePath } from "next/cache";
import { dbErrorMessage, withTransaction } from "@/lib/db";
import { cleanPlateString, formatIndianPlate } from "@/lib/anpr";

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const inputReg = body.registration_no?.toString().trim().toUpperCase() ?? "";
    const cleanReg = cleanPlateString(inputReg);
    const formattedReg = formatIndianPlate(cleanReg);
    const gateId = body.entry_gate_id ? Number(body.entry_gate_id) : null;
    let typeId = body.type_id ? Number(body.type_id) : null;
    const requestedSlotId = body.slot_id ? Number(body.slot_id) : null;

    if (!cleanReg) {
      return NextResponse.json({ success: false, error: "Registration number is required." }, { status: 400 });
    }
    if (!gateId) {
      return NextResponse.json({ success: false, error: "Entry gate ID is required." }, { status: 400 });
    }

    const result = await withTransaction(async (client) => {
      // 1. Check if gate exists and is active
      const gateRes = await client.query(
        "SELECT gate_id, gate_number, zone_id FROM parking_gate WHERE gate_id = $1 AND status = 'ACTIVE' AND gate_type = 'ENTRY'",
        [gateId],
      );
      if (gateRes.rows.length === 0) {
        throw new Error("Specified entry gate is invalid or inactive.");
      }
      const gate = gateRes.rows[0];

      // 2. Lookup or auto-create vehicle using canonical registration
      let vehicle = (
        await client.query(
          "SELECT vehicle_id, type_id, registration_no FROM vehicle WHERE regexp_replace(upper(registration_no), '[^A-Z0-9]', '', 'g') = $1",
          [cleanReg]
        )
      ).rows[0];

      let isNewVehicle = false;
      if (!vehicle) {
        if (!typeId) {
          const defaultType = await client.query("SELECT type_id FROM vehicle_type ORDER BY type_id LIMIT 1");
          typeId = defaultType.rows[0]?.type_id ?? 1;
        }

        vehicle = (
          await client.query(
            "INSERT INTO vehicle (registration_no, type_id) VALUES ($1, $2) RETURNING vehicle_id, type_id, registration_no",
            [formattedReg, typeId],
          )
        ).rows[0];
        isNewVehicle = true;
      }

      // 3. Check for existing active ticket (canonical)
      const activeTicket = (
        await client.query(
          `SELECT t.ticket_no, s.slot_no, z.zone_name, to_char(t.entry_time, 'YYYY-MM-DD HH24:MI') as entry_time
             FROM parking_ticket t
             JOIN vehicle v ON v.vehicle_id = t.vehicle_id
             JOIN parking_slot s ON s.slot_id = t.slot_id
             JOIN parking_zone z ON z.zone_id = s.zone_id
            WHERE regexp_replace(upper(v.registration_no), '[^A-Z0-9]', '', 'g') = $1
              AND t.ticket_status = 'ACTIVE'`,
          [cleanReg],
        )
      ).rows[0];

      if (activeTicket) {
        return {
          alreadyParked: true,
          ticketNo: activeTicket.ticket_no,
          slotNo: activeTicket.slot_no,
          zoneName: activeTicket.zone_name,
          entryTime: activeTicket.entry_time,
          registrationNo: vehicle.registration_no,
        };
      }

      // 4. Lock available slot
      const slot = (
        requestedSlotId
          ? await client.query(
              `SELECT s.slot_id, s.slot_no, z.zone_name
                 FROM parking_slot s
                 JOIN parking_zone z ON z.zone_id = s.zone_id
                WHERE s.slot_id = $1 AND s.availability_status = 'AVAILABLE'
                FOR UPDATE`,
              [requestedSlotId],
            )
          : await client.query(
              `SELECT s.slot_id, s.slot_no, z.zone_name
                 FROM parking_slot s
                 JOIN parking_zone z ON z.zone_id = s.zone_id
                WHERE s.availability_status = 'AVAILABLE'
                ORDER BY (s.zone_id = $1) DESC, s.slot_no
                LIMIT 1
                FOR UPDATE`,
              [gate.zone_id],
            )
      ).rows[0];

      if (!slot) {
        return { noSlots: true };
      }

      // 5. Issue ticket
      const ticket = (
        await client.query(
          `INSERT INTO parking_ticket (vehicle_id, slot_id, entry_gate_id, ticket_status)
           VALUES ($1, $2, $3, 'ACTIVE')
           RETURNING ticket_no, to_char(entry_time, 'YYYY-MM-DD HH24:MI') as entry_time`,
          [vehicle.vehicle_id, slot.slot_id, gateId],
        )
      ).rows[0];

      // 6. Occupy slot
      await client.query("UPDATE parking_slot SET availability_status = 'OCCUPIED' WHERE slot_id = $1", [slot.slot_id]);

      return {
        success: true,
        ticketNo: ticket.ticket_no as number,
        slotNo: slot.slot_no as string,
        zoneName: slot.zone_name as string,
        entryTime: ticket.entry_time as string,
        gateNumber: gate.gate_number as string,
        registrationNo: vehicle.registration_no,
        isNewVehicle,
      };
    });

    if (result.alreadyParked) {
      return NextResponse.json({
        success: false,
        status: "ALREADY_PARKED",
        message: `Vehicle ${result.registrationNo} is already parked (Ticket #${result.ticketNo} in Slot ${result.slotNo}).`,
        ticketNo: result.ticketNo,
        slotNo: result.slotNo,
      });
    }

    if (result.noSlots) {
      return NextResponse.json(
        {
          success: false,
          status: "NO_SLOTS",
          message: "Parking lot is full. No available slots found.",
        },
        { status: 409 },
      );
    }

    revalidatePath("/", "layout");

    return NextResponse.json({
      success: true,
      status: "PARKED",
      message: `Ticket #${result.ticketNo} issued for ${result.registrationNo} in slot ${result.slotNo} (${result.zoneName}).`,
      data: result,
    });
  } catch (err) {
    return NextResponse.json(
      { success: false, error: dbErrorMessage(err) },
      { status: 500 },
    );
  }
}

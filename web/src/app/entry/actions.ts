"use server";

import { revalidatePath } from "next/cache";
import { dbErrorMessage, withTransaction } from "@/lib/db";

export type EntryState = { error: string | null; ticketNo?: number; message?: string };

class UserError extends Error {}

export async function parkVehicle(_prev: EntryState, formData: FormData): Promise<EntryState> {
  const reg = formData.get("registration_no")?.toString().trim().toUpperCase() ?? "";
  const gateId = formData.get("entry_gate_id")?.toString() ?? "";
  const slotChoice = formData.get("slot_id")?.toString() ?? "";
  const typeId = formData.get("type_id")?.toString() || null;
  const ownerName = formData.get("owner_name")?.toString().trim() || null;
  const ownerPhone = formData.get("owner_phone")?.toString().trim() || null;

  if (!reg || !gateId) return { error: "Registration number and entry gate are required." };

  try {
    const result = await withTransaction(async (client) => {
      // 1. Find or create the vehicle
      let vehicle = (
        await client.query("SELECT vehicle_id FROM vehicle WHERE upper(registration_no) = $1", [reg])
      ).rows[0];
      let created = false;
      if (!vehicle) {
        if (!typeId) throw new UserError("New vehicle — please choose a vehicle type.");
        vehicle = (
          await client.query(
            "INSERT INTO vehicle (registration_no, type_id, owner_name, owner_phone) VALUES ($1, $2, $3, $4) RETURNING vehicle_id",
            [reg, typeId, ownerName, ownerPhone],
          )
        ).rows[0];
        created = true;
      }

      const active = await client.query(
        "SELECT ticket_no FROM parking_ticket WHERE vehicle_id = $1 AND ticket_status = 'ACTIVE'",
        [vehicle.vehicle_id],
      );
      if (active.rows[0]) throw new UserError(`${reg} is already parked (ticket #${active.rows[0].ticket_no}).`);

      // 2. Lock an available slot (chosen, or first free one — preferring the gate's zone)
      const slot = (
        slotChoice
          ? await client.query(
              "SELECT slot_id, slot_no FROM parking_slot WHERE slot_id = $1 AND availability_status = 'AVAILABLE' FOR UPDATE",
              [slotChoice],
            )
          : await client.query(
              `SELECT s.slot_id, s.slot_no FROM parking_slot s
                WHERE s.availability_status = 'AVAILABLE'
                ORDER BY (s.zone_id = (SELECT zone_id FROM parking_gate WHERE gate_id = $1)) DESC, s.slot_no
                LIMIT 1 FOR UPDATE`,
              [gateId],
            )
      ).rows[0];
      if (!slot) throw new UserError("No available slot (it may have just been taken).");

      // 3. Issue ticket and occupy slot
      const ticket = (
        await client.query(
          "INSERT INTO parking_ticket (vehicle_id, slot_id, entry_gate_id) VALUES ($1, $2, $3) RETURNING ticket_no",
          [vehicle.vehicle_id, slot.slot_id, gateId],
        )
      ).rows[0];
      await client.query("UPDATE parking_slot SET availability_status = 'OCCUPIED' WHERE slot_id = $1", [slot.slot_id]);

      return { ticketNo: ticket.ticket_no as number, slotNo: slot.slot_no as string, created };
    });

    revalidatePath("/", "layout");
    return {
      error: null,
      ticketNo: result.ticketNo,
      message: `Ticket #${result.ticketNo} issued for ${reg} → slot ${result.slotNo}${result.created ? " (new vehicle registered)" : ""}.`,
    };
  } catch (err) {
    return { error: err instanceof UserError ? err.message : dbErrorMessage(err) };
  }
}

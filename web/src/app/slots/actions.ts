"use server";

import { revalidatePath } from "next/cache";
import { pool } from "@/lib/db";

/** Switch a slot between AVAILABLE and MAINTENANCE, or free an OCCUPIED slot that has no active ticket. */
export async function setSlotStatus(slotId: number, status: "AVAILABLE" | "MAINTENANCE") {
  await pool.query(
    `UPDATE parking_slot SET availability_status = $2
      WHERE slot_id = $1
        AND NOT EXISTS (SELECT 1 FROM parking_ticket WHERE slot_id = $1 AND ticket_status = 'ACTIVE')`,
    [slotId, status],
  );
  revalidatePath("/slots");
  revalidatePath("/");
}

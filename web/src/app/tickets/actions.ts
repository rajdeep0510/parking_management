"use server";

import { revalidatePath } from "next/cache";
import { withTransaction } from "@/lib/db";

export async function cancelTicket(ticketNo: number) {
  await withTransaction(async (client) => {
    const { rows } = await client.query(
      "UPDATE parking_ticket SET ticket_status = 'CANCELLED' WHERE ticket_no = $1 AND ticket_status = 'ACTIVE' RETURNING slot_id",
      [ticketNo],
    );
    if (rows[0]) {
      await client.query("UPDATE parking_slot SET availability_status = 'AVAILABLE' WHERE slot_id = $1", [rows[0].slot_id]);
    }
  });
  revalidatePath("/", "layout");
}

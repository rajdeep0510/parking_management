"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { dbErrorMessage, withTransaction } from "@/lib/db";
import { getFareQuote } from "@/lib/fare";

export type ExitState = { error: string | null };

class UserError extends Error {}

export async function processExit(ticketNo: number, _prev: ExitState, formData: FormData): Promise<ExitState> {
  const gateId = formData.get("exit_gate_id")?.toString();
  const mode = formData.get("payment_mode")?.toString();
  if (!gateId || !mode) return { error: "Choose an exit gate and payment mode." };

  try {
    await withTransaction(async (client) => {
      // Lock the ticket so a double-submit can't create two exits.
      await client.query("SELECT 1 FROM parking_ticket WHERE ticket_no = $1 FOR UPDATE", [ticketNo]);
      const q = await getFareQuote(client, ticketNo);
      if (!q) throw new UserError("Ticket not found.");
      if (q.ticket_status !== "ACTIVE") throw new UserError(`Ticket is already ${q.ticket_status}.`);
      if (q.error) throw new UserError(q.error);

      const exit = (
        await client.query(
          `INSERT INTO parking_exit (ticket_no, exit_time, exit_gate_id, total_hours, total_amount)
           VALUES ($1, $2, $3, $4, $5) RETURNING exit_id`,
          [ticketNo, q.exit_time, gateId, q.total_hours, q.amount],
        )
      ).rows[0];
      await client.query("UPDATE parking_ticket SET ticket_status = 'COMPLETED' WHERE ticket_no = $1", [ticketNo]);
      await client.query("UPDATE parking_slot SET availability_status = 'AVAILABLE' WHERE slot_id = $1", [q.slot_id]);
      await client.query(
        `INSERT INTO payment_details (exit_id, payment_mode, payment_status, amount_paid)
         VALUES ($1, $2, 'SUCCESSFUL', $3)`,
        [exit.exit_id, mode, q.amount],
      );
    });
  } catch (err) {
    return { error: err instanceof UserError ? err.message : dbErrorMessage(err) };
  }

  revalidatePath("/", "layout");
  redirect(`/exit/${ticketNo}`);
}

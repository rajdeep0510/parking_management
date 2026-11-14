import { Suspense } from "react";
import Link from "next/link";
import { query } from "@/lib/db";
import { StatusBadge } from "@/components/StatusBadge";

export default function HistoryPage() {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <HistoryPageContent />
    </Suspense>
  );
}

async function HistoryPageContent() {
  const rows = await query<{
    ticket_no: number;
    registration_no: string;
    slot_no: string;
    ticket_status: string;
    entry_time: string;
    exit_time: string | null;
    total_hours: number | null;
    total_amount: number | null;
    payment_mode: string | null;
    payment_status: string | null;
  }>(
    `SELECT t.ticket_no, v.registration_no, s.slot_no, t.ticket_status,
            to_char(t.entry_time, 'YYYY-MM-DD HH24:MI') AS entry_time,
            to_char(e.exit_time, 'YYYY-MM-DD HH24:MI') AS exit_time,
            e.total_hours, e.total_amount, p.payment_mode, p.payment_status
       FROM parking_ticket t
       JOIN vehicle v ON v.vehicle_id = t.vehicle_id
       JOIN parking_slot s ON s.slot_id = t.slot_id
       LEFT JOIN parking_exit e ON e.ticket_no = t.ticket_no
       LEFT JOIN payment_details p ON p.exit_id = e.exit_id
      WHERE t.ticket_status <> 'ACTIVE'
      ORDER BY COALESCE(e.exit_time, t.entry_time) DESC
      LIMIT 200`,
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="page-title">History</h1>
        <p className="page-subtitle">Last {rows.length} closed tickets</p>
      </div>
      <div className="card overflow-hidden p-0 md:overflow-x-auto">
        <table className="table table-stack">
          <thead>
            <tr>
              <th>Ticket</th>
              <th>Vehicle</th>
              <th>Slot</th>
              <th>Status</th>
              <th>Entry</th>
              <th>Exit</th>
              <th>Hours</th>
              <th>Amount</th>
              <th>Payment</th>
            </tr>
          </thead>
          <tbody>
            {rows.length === 0 && (
              <tr>
                <td colSpan={9} className="cell-empty text-center text-muted">
                  No completed tickets yet
                </td>
              </tr>
            )}
            {rows.map((r) => (
              <tr key={r.ticket_no}>
                <td className="cell-primary">
                  <Link href={`/exit/${r.ticket_no}`} className="text-accent hover:underline">
                    #{r.ticket_no}
                  </Link>
                </td>
                <td data-label="Vehicle" className="font-mono">
                  {r.registration_no}
                </td>
                <td data-label="Slot">{r.slot_no}</td>
                <td data-label="Status">
                  <StatusBadge value={r.ticket_status} />
                </td>
                <td data-label="Entry" className="tabular-nums">
                  {r.entry_time}
                </td>
                <td data-label="Exit" className="tabular-nums">
                  {r.exit_time ?? "—"}
                </td>
                <td data-label="Hours" className="tabular-nums">
                  {r.total_hours ?? "—"}
                </td>
                <td data-label="Amount" className="tabular-nums font-medium">
                  {r.total_amount != null ? `₹${r.total_amount.toFixed(2)}` : "—"}
                </td>
                <td data-label="Payment">{r.payment_mode ? `${r.payment_mode} · ${r.payment_status}` : "—"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

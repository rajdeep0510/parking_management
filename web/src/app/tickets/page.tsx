import { Suspense } from "react";
import Link from "next/link";
import { query } from "@/lib/db";
import { Icon } from "@/components/Icon";
import { LicensePlate } from "@/components/LicensePlate";
import { VehicleBadge } from "@/components/VehicleBadge";
import { cancelTicket } from "./actions";

export default function TicketsPage() {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <TicketsPageContent />
    </Suspense>
  );
}

async function TicketsPageContent() {
  const tickets = await query<{
    ticket_no: number;
    registration_no: string;
    type_name: string;
    slot_no: string;
    zone_name: string;
    gate_number: string;
    entry_time: string;
    duration: string;
  }>(
    `SELECT t.ticket_no, v.registration_no, vt.type_name, s.slot_no, z.zone_name, g.gate_number,
            to_char(t.entry_time, 'YYYY-MM-DD HH24:MI') AS entry_time,
            to_char(LOCALTIMESTAMP - t.entry_time, 'FMDD"d" HH24"h" MI"m"') AS duration
       FROM parking_ticket t
       JOIN vehicle v ON v.vehicle_id = t.vehicle_id
       JOIN vehicle_type vt ON vt.type_id = v.type_id
       JOIN parking_slot s ON s.slot_id = t.slot_id
       JOIN parking_zone z ON z.zone_id = s.zone_id
       JOIN parking_gate g ON g.gate_id = t.entry_gate_id
      WHERE t.ticket_status = 'ACTIVE'
      ORDER BY t.entry_time`,
  );

  return (
    <div className="space-y-6">
      <div className="animate-reveal flex items-end justify-between gap-3">
        <div>
          <h1 className="page-title">Active Tickets</h1>
          <p className="page-subtitle">
            {tickets.length} {tickets.length === 1 ? "vehicle" : "vehicles"} parked
          </p>
        </div>
        <Link href="/entry" className="btn-primary">
          <Icon name="plus" className="h-4 w-4" />
          New entry
        </Link>
      </div>
      <div className="card animate-reveal-stagger-1 overflow-hidden p-0 md:overflow-x-auto">
        <table className="table table-stack">
          <thead>
            <tr>
              <th>Vehicle</th>
              <th>Type</th>
              <th>Slot</th>
              <th>Entry gate</th>
              <th>Entry time</th>
              <th>Parked for</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {tickets.length === 0 && (
              <tr>
                <td colSpan={7} className="cell-empty text-center text-muted">
                  No vehicles parked right now
                </td>
              </tr>
            )}
            {tickets.map((t) => (
              <tr key={t.ticket_no} className="group">
                <td className="cell-primary">
                  <div className="flex items-center gap-2">
                    <LicensePlate plate={t.registration_no} ticketNo={t.ticket_no} size="md" />
                    <span className="text-xs font-medium text-muted">#{t.ticket_no}</span>
                  </div>
                </td>
                <td data-label="Type">
                  <VehicleBadge typeName={t.type_name} />
                </td>
                <td data-label="Slot">
                  <span className="font-semibold">{t.slot_no}</span>{" "}
                  <span className="text-muted">· {t.zone_name}</span>
                </td>
                <td data-label="Entry gate">{t.gate_number}</td>
                <td data-label="Entry time" className="tabular-nums text-xs sm:text-sm">
                  {t.entry_time}
                </td>
                <td data-label="Parked for" className="tabular-nums font-medium text-xs sm:text-sm">
                  <span className="inline-flex items-center gap-1 rounded bg-accent-soft px-2 py-0.5 text-accent font-semibold">
                    {t.duration}
                  </span>
                </td>
                <td className="cell-actions">
                  <div className="flex justify-end gap-2">
                    <form action={cancelTicket.bind(null, t.ticket_no)}>
                      <button className="btn-danger">Cancel</button>
                    </form>
                    <Link href={`/exit/${t.ticket_no}`} className="btn-primary">
                      <Icon name="exit" className="h-4 w-4" />
                      Exit
                    </Link>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

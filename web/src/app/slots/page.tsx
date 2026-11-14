import { Suspense } from "react";
import Link from "next/link";
import { query } from "@/lib/db";
import { Icon } from "@/components/Icon";
import { setSlotStatus } from "./actions";

type SlotRow = {
  slot_id: number;
  slot_no: string;
  zone_id: number;
  zone_name: string;
  slot_type_name: string;
  availability_status: string;
  ticket_no: number | null;
  registration_no: string | null;
};

const TILE: Record<string, string> = {
  AVAILABLE: "border-green-500/30 bg-green-500/[0.07]",
  OCCUPIED: "border-red-500/30 bg-red-500/[0.07]",
  MAINTENANCE: "border-amber-500/30 bg-amber-500/[0.07]",
};

const DOT: Record<string, string> = {
  AVAILABLE: "bg-green-500",
  OCCUPIED: "bg-red-500",
  MAINTENANCE: "bg-amber-500",
};

export default function SlotBoard() {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <SlotBoardContent />
    </Suspense>
  );
}

async function SlotBoardContent() {
  const slots = await query<SlotRow>(
    `SELECT s.slot_id, s.slot_no, s.zone_id, z.zone_name, st.slot_type_name, s.availability_status,
            t.ticket_no, v.registration_no
       FROM parking_slot s
       JOIN parking_zone z ON z.zone_id = s.zone_id
       JOIN slot_type st ON st.slot_type_id = s.slot_type_id
       LEFT JOIN parking_ticket t ON t.slot_id = s.slot_id AND t.ticket_status = 'ACTIVE'
       LEFT JOIN vehicle v ON v.vehicle_id = t.vehicle_id
      ORDER BY z.floor_level, z.zone_name, s.slot_no`,
  );

  const zones = new Map<string, SlotRow[]>();
  for (const s of slots) zones.set(s.zone_name, [...(zones.get(s.zone_name) ?? []), s]);

  const counts = Object.keys(DOT).map((status) => [status, slots.filter((s) => s.availability_status === status).length] as const);

  return (
    <div className="space-y-5 sm:space-y-6">
      <div className="flex items-end justify-between gap-3">
        <div>
          <h1 className="page-title">Slot Board</h1>
          <p className="page-subtitle">{slots.length} slots across {zones.size} zones</p>
        </div>
        <Link href="/slots/manage" className="btn">
          <Icon name="wrench" className="h-4 w-4" />
          Manage
        </Link>
      </div>

      <div className="flex flex-wrap gap-2">
        {counts.map(([status, n]) => (
          <span key={status} className="inline-flex items-center gap-2 rounded-full border border-border bg-surface px-3 py-1.5 text-sm">
            <span className={`h-2.5 w-2.5 rounded-full ${DOT[status]}`} />
            <span className="capitalize text-muted">{status.toLowerCase()}</span>
            <span className="font-semibold tabular-nums">{n}</span>
          </span>
        ))}
      </div>

      {slots.length === 0 && <p className="text-muted">No slots yet. Add some on the Manage slots page.</p>}
      {[...zones].map(([zone, zoneSlots]) => {
        const free = zoneSlots.filter((s) => s.availability_status === "AVAILABLE").length;
        return (
          <section key={zone} className="card">
            <div className="mb-3 flex items-center justify-between gap-2">
              <h2 className="font-semibold">{zone}</h2>
              <span className="text-sm text-muted tabular-nums">
                {free}/{zoneSlots.length} free
              </span>
            </div>
            <div className="grid grid-cols-2 gap-2.5 min-[420px]:grid-cols-3 sm:grid-cols-4 lg:grid-cols-6">
              {zoneSlots.map((s) => (
                <div key={s.slot_id} className={`flex flex-col rounded-lg border p-3 text-sm ${TILE[s.availability_status]}`}>
                  <div className="flex items-center justify-between gap-2">
                    <span className="font-semibold">{s.slot_no}</span>
                    <span className={`h-2.5 w-2.5 rounded-full ${DOT[s.availability_status]}`} title={s.availability_status} />
                  </div>
                  <div className="truncate text-xs text-muted">{s.slot_type_name}</div>
                  <div className="mt-auto pt-2">
                    {s.ticket_no ? (
                      <Link
                        href={`/exit/${s.ticket_no}`}
                        className="flex min-h-8 items-center justify-between gap-1 rounded-md bg-surface px-2 text-xs font-medium hover:text-accent"
                      >
                        <span className="truncate font-mono">{s.registration_no}</span>
                        <Icon name="exit" className="h-3.5 w-3.5 shrink-0" />
                      </Link>
                    ) : s.availability_status === "AVAILABLE" ? (
                      <form action={setSlotStatus.bind(null, s.slot_id, "MAINTENANCE")}>
                        <button className="min-h-8 w-full rounded-md px-2 text-left text-xs text-muted hover:bg-surface hover:text-foreground">
                          Set maintenance
                        </button>
                      </form>
                    ) : (
                      <form action={setSlotStatus.bind(null, s.slot_id, "AVAILABLE")}>
                        <button className="min-h-8 w-full rounded-md px-2 text-left text-xs text-muted hover:bg-surface hover:text-foreground">
                          Mark available
                        </button>
                      </form>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </section>
        );
      })}
    </div>
  );
}

import { Suspense } from "react";
import Link from "next/link";
import { query } from "@/lib/db";
import { Icon } from "@/components/Icon";

export default function Dashboard() {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <DashboardContent />
    </Suspense>
  );
}

async function DashboardContent() {
  const [[slots], [tickets], [revenue], zones] = await Promise.all([
    query<{ total: number; available: number; occupied: number; maintenance: number }>(
      `SELECT count(*) AS total,
              count(*) FILTER (WHERE availability_status = 'AVAILABLE') AS available,
              count(*) FILTER (WHERE availability_status = 'OCCUPIED') AS occupied,
              count(*) FILTER (WHERE availability_status = 'MAINTENANCE') AS maintenance
         FROM parking_slot`,
    ),
    query<{ active: number }>(`SELECT count(*) AS active FROM parking_ticket WHERE ticket_status = 'ACTIVE'`),
    query<{ today: number; total: number }>(
      `SELECT COALESCE(SUM(amount_paid) FILTER (WHERE transaction_time::date = CURRENT_DATE), 0) AS today,
              COALESCE(SUM(amount_paid), 0) AS total
         FROM payment_details WHERE payment_status = 'SUCCESSFUL'`,
    ),
    query<{ zone_id: number; zone_name: string; floor_level: number; total_capacity: number; slots: number; occupied: number }>(
      `SELECT z.zone_id, z.zone_name, z.floor_level, z.total_capacity,
              count(s.slot_id) AS slots,
              count(s.slot_id) FILTER (WHERE s.availability_status = 'OCCUPIED') AS occupied
         FROM parking_zone z LEFT JOIN parking_slot s ON s.zone_id = z.zone_id
        GROUP BY z.zone_id ORDER BY z.floor_level, z.zone_name`,
    ),
  ]);

  const occupancyPct = slots.total ? Math.round((slots.occupied / slots.total) * 100) : 0;
  const segments = [
    ["Available", slots.available, "bg-green-500", "text-green-600 dark:text-green-400"],
    ["Occupied", slots.occupied, "bg-red-500", "text-red-600 dark:text-red-400"],
    ["Maintenance", slots.maintenance, "bg-amber-500", "text-amber-600 dark:text-amber-400"],
  ] as const;
  const stats = [
    ["Active tickets", tickets.active, "ticket", "/tickets"],
    ["Revenue today", `₹${revenue.today.toFixed(2)}`, "rupee", "/history"],
    ["Revenue (all time)", `₹${revenue.total.toFixed(2)}`, "history", "/history"],
  ] as const;

  return (
    <div className="space-y-5 sm:space-y-6">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="page-title">Dashboard</h1>
          <p className="page-subtitle">Live overview of the parking facility</p>
        </div>
        <div className="grid w-full grid-cols-2 gap-2 sm:flex sm:w-auto">
          <Link href="/entry" className="btn-primary">
            <Icon name="plus" className="h-4 w-4" />
            New entry
          </Link>
          <Link href="/tickets" className="btn">
            <Icon name="exit" className="h-4 w-4" />
            Process exit
          </Link>
        </div>
      </div>

      <div className="grid gap-3 sm:gap-4 lg:grid-cols-3">
        <section className="card lg:col-span-2">
          <div className="flex items-start justify-between gap-4">
            <div>
              <h2 className="text-sm font-medium text-muted">Occupancy</h2>
              <div className="mt-1 flex items-baseline gap-2">
                <span className="text-4xl font-semibold tracking-tight tabular-nums">{occupancyPct}%</span>
                <span className="text-sm text-muted tabular-nums">
                  {slots.occupied} of {slots.total} slots
                </span>
              </div>
            </div>
            <Link href="/slots" className="btn shrink-0">
              <Icon name="grid" className="h-4 w-4" />
              <span className="hidden sm:inline">Slot board</span>
            </Link>
          </div>
          <div className="mt-4 flex h-3 overflow-hidden rounded-full bg-surface-2">
            {segments.map(([label, n, bar]) =>
              n > 0 ? <div key={label} className={bar} style={{ width: `${(n / slots.total) * 100}%` }} /> : null,
            )}
          </div>
          <div className="mt-4 grid grid-cols-3 gap-2">
            {segments.map(([label, n, bar, text]) => (
              <div key={label} className="rounded-lg bg-surface-2 px-3 py-2.5">
                <div className="flex items-center gap-1.5 text-xs text-muted">
                  <span className={`h-2 w-2 rounded-full ${bar}`} />
                  <span className="truncate">{label}</span>
                </div>
                <div className={`mt-0.5 text-xl font-semibold tabular-nums ${text}`}>{n}</div>
              </div>
            ))}
          </div>
        </section>

        <div className="grid grid-cols-2 gap-3 sm:gap-4 lg:grid-cols-1">
          {stats.map(([label, value, icon, href], i) => (
            <Link
              key={label}
              href={href}
              className={`card flex items-center gap-3 transition hover:border-accent/40 ${i === 0 ? "col-span-2 lg:col-span-1" : ""}`}
            >
              <span className="grid h-10 w-10 shrink-0 place-items-center rounded-lg bg-accent-soft text-accent">
                <Icon name={icon} />
              </span>
              <div className="min-w-0">
                <div className="truncate text-xs text-muted sm:text-sm">{label}</div>
                <div className="truncate text-lg font-semibold tabular-nums sm:text-xl">{value}</div>
              </div>
            </Link>
          ))}
        </div>
      </div>

      <section className="card">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="font-semibold">Zones</h2>
          <Link href="/zones" className="text-sm text-accent hover:underline">
            Manage
          </Link>
        </div>
        <div className="grid gap-4 sm:grid-cols-2">
          {zones.map((z) => {
            const pct = z.slots ? Math.round((z.occupied / z.slots) * 100) : 0;
            const bar = pct >= 90 ? "bg-red-500" : pct >= 60 ? "bg-amber-500" : "bg-green-500";
            return (
              <div key={z.zone_id} className="rounded-lg border border-border p-3">
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <div className="truncate font-medium">{z.zone_name}</div>
                    <div className="text-xs text-muted">
                      Floor {z.floor_level} · capacity {z.total_capacity}
                    </div>
                  </div>
                  <span className="text-sm font-semibold tabular-nums">{pct}%</span>
                </div>
                <div className="mt-2.5 h-2 rounded-full bg-surface-2">
                  <div className={`h-2 rounded-full ${bar}`} style={{ width: `${pct}%` }} />
                </div>
                <div className="mt-1.5 text-xs text-muted tabular-nums">
                  {z.occupied}/{z.slots} slots occupied
                </div>
              </div>
            );
          })}
          {zones.length === 0 && <p className="text-sm text-muted">No zones configured.</p>}
        </div>
      </section>
    </div>
  );
}

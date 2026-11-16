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
  const [[slots], [tickets], [revenue], zones, [passes]] = await Promise.all([
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
    query<{ activePasses: number }>(
      `SELECT count(*) AS activePasses FROM membership_pass WHERE status = 'ACTIVE'`,
    ),
  ]);

  const occupancyPct = slots.total ? Math.round((slots.occupied / slots.total) * 100) : 0;
  const availablePct = slots.total ? Math.round((slots.available / slots.total) * 100) : 0;

  const stats = [
    { label: "Active tickets", value: tickets.active, subtext: "Live inside", icon: "ticket", href: "/tickets", accent: "text-rose-500", bg: "bg-rose-500/10" },
    { label: "Revenue today", value: `₹${revenue.today.toFixed(2)}`, subtext: "Today's collection", icon: "rupee", href: "/history", accent: "text-emerald-500", bg: "bg-emerald-500/10" },
    { label: "Total revenue", value: `₹${revenue.total.toFixed(2)}`, subtext: "All time total", icon: "trendingUp", href: "/history", accent: "text-indigo-500", bg: "bg-indigo-500/10" },
    { label: "Active passes", value: passes?.activePasses ?? 0, subtext: "Permits registered", icon: "badge", href: "/passes", accent: "text-amber-500", bg: "bg-amber-500/10" },
  ] as const;

  return (
    <div className="space-y-6">
      {/* Header with Quick Actions */}
      <div className="animate-reveal flex flex-wrap items-end justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/10 px-2.5 py-0.5 text-xs font-semibold text-emerald-600 dark:text-emerald-400">
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
              Live Facility Status
            </span>
          </div>
          <h1 className="page-title">Dashboard</h1>
          <p className="page-subtitle">Real-time facility occupancy, revenue & zone capacity</p>
        </div>
        <div className="grid w-full grid-cols-2 sm:flex sm:w-auto gap-2.5">
          <Link href="/entry" className="btn-primary">
            <Icon name="plus" className="h-4 w-4" />
            New entry
          </Link>
          <Link href="/anpr" className="btn">
            <Icon name="camera" className="h-4 w-4" />
            Camera scanner
          </Link>
          <Link href="/tickets" className="btn">
            <Icon name="exit" className="h-4 w-4" />
            Process exit
          </Link>
        </div>
      </div>

      {/* Main Grid: Occupancy Ring + Key Metric Cards */}
      <div className="grid gap-4 lg:grid-cols-3">
        {/* Radial Occupancy Card */}
        <section className="card animate-reveal-stagger-1 lg:col-span-2 flex flex-col justify-between">
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div>
              <h2 className="text-sm font-semibold uppercase tracking-wider text-muted">Facility Occupancy</h2>
              <p className="text-xs text-muted mt-0.5">Automated real-time slot telemetry</p>
            </div>
            <Link href="/slots" className="btn shrink-0 text-xs">
              <Icon name="grid" className="h-3.5 w-3.5" />
              <span>Full Slot Board</span>
            </Link>
          </div>

          <div className="my-5 flex flex-col sm:flex-row items-center gap-6 sm:gap-8">
            {/* Semantic Accessible Progress Ring (Modern Web Guidance) */}
            <div className="progress-ring-wrapper shrink-0">
              <progress
                value={occupancyPct}
                max={100}
                aria-label="Facility occupancy rate"
                aria-valuetext={`${occupancyPct}% of slots occupied`}
                className="progress-ring"
                style={
                  {
                    "--value": occupancyPct,
                    "--fill-color":
                      occupancyPct >= 90
                        ? "#f43f5e"
                        : occupancyPct >= 70
                        ? "#f59e0b"
                        : "#4f46e5",
                  } as React.CSSProperties
                }
              />
              <div className="progress-ring-content" aria-hidden="true">
                <span className="text-3xl font-extrabold tracking-tight tabular-nums text-foreground">
                  {occupancyPct}%
                </span>
                <span className="text-[10px] font-bold uppercase tracking-wider text-muted">
                  Occupied
                </span>
              </div>
            </div>

            {/* Segment Breakdown & Progress Bar */}
            <div className="flex-1 w-full min-w-0 space-y-4">
              <div>
                <div className="flex justify-between text-xs text-muted mb-1.5">
                  <span>Capacity Utilization</span>
                  <span className="font-semibold text-foreground tabular-nums">
                    {slots.occupied} / {slots.total} slots
                  </span>
                </div>
                <div className="flex h-3.5 overflow-hidden rounded-full bg-surface-2 p-0.5 ring-1 ring-black/5 dark:ring-white/5">
                  {slots.occupied > 0 && (
                    <div
                      className="bg-rose-500 rounded-l-full transition-all duration-500 ease-out"
                      style={{ width: `${(slots.occupied / slots.total) * 100}%` }}
                      title={`Occupied: ${slots.occupied}`}
                    />
                  )}
                  {slots.available > 0 && (
                    <div
                      className="bg-emerald-500 transition-all duration-500 ease-out"
                      style={{ width: `${(slots.available / slots.total) * 100}%` }}
                      title={`Available: ${slots.available}`}
                    />
                  )}
                  {slots.maintenance > 0 && (
                    <div
                      className="bg-amber-500 rounded-r-full transition-all duration-500 ease-out"
                      style={{ width: `${(slots.maintenance / slots.total) * 100}%` }}
                      title={`Maintenance: ${slots.maintenance}`}
                    />
                  )}
                </div>
              </div>

              {/* Segment Tiles */}
              <div className="grid grid-cols-3 gap-2">
                <div className="rounded-xl border border-emerald-500/20 bg-emerald-500/5 p-2.5 transition-all duration-150 hover:bg-emerald-500/10">
                  <div className="flex items-center gap-1.5 text-xs font-medium text-emerald-700 dark:text-emerald-400">
                    <span className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                    Available
                  </div>
                  <div className="mt-1 text-xl font-bold tabular-nums text-emerald-700 dark:text-emerald-300">
                    {slots.available}
                  </div>
                  <div className="text-[10px] text-muted">{availablePct}% of total</div>
                </div>

                <div className="rounded-xl border border-rose-500/20 bg-rose-500/5 p-2.5 transition-all duration-150 hover:bg-rose-500/10">
                  <div className="flex items-center gap-1.5 text-xs font-medium text-rose-700 dark:text-rose-400">
                    <span className="h-2 w-2 rounded-full bg-rose-500" />
                    Occupied
                  </div>
                  <div className="mt-1 text-xl font-bold tabular-nums text-rose-700 dark:text-rose-300">
                    {slots.occupied}
                  </div>
                  <div className="text-[10px] text-muted">{occupancyPct}% of total</div>
                </div>

                <div className="rounded-xl border border-amber-500/20 bg-amber-500/5 p-2.5 transition-all duration-150 hover:bg-amber-500/10">
                  <div className="flex items-center gap-1.5 text-xs font-medium text-amber-700 dark:text-amber-400">
                    <span className="h-2 w-2 rounded-full bg-amber-500" />
                    Maintenance
                  </div>
                  <div className="mt-1 text-xl font-bold tabular-nums text-amber-700 dark:text-amber-300">
                    {slots.maintenance}
                  </div>
                  <div className="text-[10px] text-muted">Out of service</div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* 4 Metric Cards */}
        <div className="grid grid-cols-2 gap-3 sm:gap-4 lg:grid-cols-1">
          {stats.map((s, i) => (
            <Link
              key={s.label}
              href={s.href}
              className={`card-interactive group animate-reveal-stagger-2 flex items-center justify-between p-3.5 sm:p-4`}
              style={{ animationDelay: `${(i + 1) * 50}ms` }}
            >
              <div className="flex items-center gap-3 min-w-0">
                <span className={`grid h-11 w-11 shrink-0 place-items-center rounded-xl ${s.bg} ${s.accent} shadow-2xs transition-transform duration-200 group-hover:scale-110`}>
                  <Icon name={s.icon as any} className="h-5 w-5" />
                </span>
                <div className="min-w-0">
                  <div className="truncate text-xs font-medium text-muted">{s.label}</div>
                  <div className="truncate text-lg font-bold tabular-nums tracking-tight sm:text-xl text-foreground">
                    {s.value}
                  </div>
                </div>
              </div>
              <span className="text-[10px] font-semibold text-muted bg-surface-2 px-2 py-1 rounded-md shrink-0 hidden sm:inline-block">
                {s.subtext}
              </span>
            </Link>
          ))}
        </div>
      </div>

      {/* Zones & Floor Visualizer */}
      <section className="card animate-reveal-stagger-3">
        <div className="mb-4 flex items-center justify-between">
          <div>
            <h2 className="font-semibold">Parking Zones & Floor Capacities</h2>
            <p className="text-xs text-muted">Live distribution across {zones.length} levels</p>
          </div>
          <Link href="/zones" className="text-sm font-semibold text-accent transition-colors hover:underline">
            Manage zones →
          </Link>
        </div>
        <div className="grid gap-3.5 sm:grid-cols-2 lg:grid-cols-3">
          {zones.map((z) => {
            const pct = z.slots ? Math.round((z.occupied / z.slots) * 100) : 0;
            const freeCount = Math.max(0, z.slots - z.occupied);
            const isHigh = pct >= 85;
            const isMid = pct >= 60 && pct < 85;

            const barColor = isHigh ? "bg-rose-500" : isMid ? "bg-amber-500" : "bg-emerald-500";
            const badgeColor = isHigh
              ? "bg-rose-500/10 text-rose-600 dark:text-rose-400 border-rose-500/20"
              : isMid
              ? "bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20"
              : "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/20";

            return (
              <Link
                key={z.zone_id}
                href="/slots"
                className="group card-interactive p-4 border border-border/80 flex flex-col justify-between"
              >
                <div>
                  <div className="flex items-start justify-between gap-2 mb-2">
                    <div className="min-w-0">
                      <div className="flex items-center gap-1.5">
                        <span className="text-xs font-semibold px-1.5 py-0.5 rounded bg-surface-2 text-muted">
                          Floor {z.floor_level}
                        </span>
                        <span className="font-bold text-foreground truncate group-hover:text-accent transition-colors">
                          {z.zone_name}
                        </span>
                      </div>
                    </div>
                    <span className={`text-xs font-bold px-2 py-0.5 rounded-full border ${badgeColor} tabular-nums`}>
                      {pct}% Full
                    </span>
                  </div>

                  {/* Zone Mini Progress Bar */}
                  <div className="h-2 rounded-full bg-surface-2 overflow-hidden my-3 ring-1 ring-black/5 dark:ring-white/5">
                    <div
                      className={`h-full ${barColor} transition-all duration-500 ease-out`}
                      style={{ width: `${pct}%` }}
                    />
                  </div>
                </div>

                <div className="flex items-center justify-between text-xs text-muted pt-2 border-t border-border/50">
                  <span className="tabular-nums font-medium text-foreground">
                    {freeCount} free
                  </span>
                  <span className="tabular-nums">
                    {z.occupied} / {z.slots} occupied
                  </span>
                </div>
              </Link>
            );
          })}
          {zones.length === 0 && <p className="text-sm text-muted">No zones configured.</p>}
        </div>
      </section>
    </div>
  );
}

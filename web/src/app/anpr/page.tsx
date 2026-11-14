import { Suspense } from "react";
import Link from "next/link";
import { query } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { PlateScanner, type GateOption } from "@/components/PlateScanner";

type TypeOption = { value: number; label: string };

export const metadata = {
  title: "Gate Scanner Terminal - Parking Management",
};

type PageProps = {
  searchParams?: Promise<{ mode?: string; gateId?: string }>;
};

export default function AnprPage({ searchParams }: PageProps) {
  return (
    <Suspense fallback={<p className="text-muted">Loading gate scanner…</p>}>
      <AnprContent searchParams={searchParams} />
    </Suspense>
  );
}

async function AnprContent({ searchParams }: PageProps) {
  const [params, user, gates, vehicleTypes] = await Promise.all([
    searchParams ? searchParams : Promise.resolve({} as { mode?: string; gateId?: string }),
    getCurrentUser(),
    query<GateOption>(
      `SELECT g.gate_id AS value,
              g.gate_number || ' – ' || z.zone_name AS label,
              g.gate_type,
              g.gate_number,
              z.zone_name
         FROM parking_gate g
         JOIN parking_zone z ON z.zone_id = g.zone_id
        WHERE g.status = 'ACTIVE'
        ORDER BY g.gate_type, g.gate_number`
    ),
    query<TypeOption>("SELECT type_id AS value, type_name AS label FROM vehicle_type ORDER BY type_name"),
  ]);

  const requestedMode = (params.mode?.toUpperCase() === "EXIT" ? "EXIT" : params.mode?.toUpperCase() === "ENTRY" ? "ENTRY" : user?.gate_mode || "ENTRY") as "ENTRY" | "EXIT";
  const requestedGateId = params.gateId ? Number(params.gateId) : (user?.gate_id ?? undefined);

  return (
    <div className="space-y-6">
      <div className="animate-reveal flex flex-wrap items-end justify-between gap-3">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="inline-flex items-center gap-1.5 rounded-md bg-accent-soft px-2 py-0.5 text-xs font-semibold text-accent shadow-2xs">
              <span className="h-1.5 w-1.5 rounded-full bg-accent animate-pulse" />
              Gate Terminal
            </span>
            {user && (
              <span className="text-xs text-muted">
                Operator: <strong className="text-foreground">{user.display_name}</strong> ({user.role})
              </span>
            )}
          </div>
          <h1 className="page-title">ANPR Gate Scanner</h1>
          <p className="page-subtitle">
            Entry scanning fills available slots (OCCUPIED). Exit scanning frees slots (AVAILABLE) and processes payments.
          </p>
        </div>

        <div className="grid w-full grid-cols-2 gap-2 sm:flex sm:w-auto">
          <Link href="/entry" className="btn">
            Manual entry
          </Link>
          <Link href="/tickets" className="btn">
            Active tickets
          </Link>
        </div>
      </div>

      <div className="animate-reveal-stagger-1">
        {gates.length === 0 ? (
          <div className="card border-red-500/20 bg-red-500/5">
            <p className="error">
              No active parking gates configured. Please <Link href="/gates" className="underline font-medium">add or activate gates</Link> first.
            </p>
          </div>
        ) : (
          <PlateScanner
            gates={gates}
            vehicleTypes={vehicleTypes}
            initialMode={requestedMode}
            initialGateId={requestedGateId}
          />
        )}
      </div>
    </div>
  );
}

import { Suspense } from "react";
import Link from "next/link";
import { query } from "@/lib/db";
import { Icon } from "@/components/Icon";
import { EntryForm } from "./EntryForm";

type Option = { value: number; label: string };

export default function EntryPage() {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <EntryPageContent />
    </Suspense>
  );
}

async function EntryPageContent() {
  const [gates, slots, vehicleTypes, vehicles] = await Promise.all([
    query<Option>(
      `SELECT g.gate_id AS value, g.gate_number || ' – ' || z.zone_name AS label
         FROM parking_gate g JOIN parking_zone z ON z.zone_id = g.zone_id
        WHERE g.gate_type = 'ENTRY' AND g.status = 'ACTIVE' ORDER BY g.gate_number`,
    ),
    query<Option>(
      `SELECT s.slot_id AS value, s.slot_no || ' – ' || z.zone_name || ' (' || st.slot_type_name || ')' AS label
         FROM parking_slot s
         JOIN parking_zone z ON z.zone_id = s.zone_id
         JOIN slot_type st ON st.slot_type_id = s.slot_type_id
        WHERE s.availability_status = 'AVAILABLE' ORDER BY s.slot_no`,
    ),
    query<Option>("SELECT type_id AS value, type_name AS label FROM vehicle_type ORDER BY type_name"),
    query<{ registration_no: string }>("SELECT registration_no FROM vehicle ORDER BY registration_no"),
  ]);

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="page-title">Vehicle Entry</h1>
          <p className="page-subtitle">Issue a parking ticket manually</p>
        </div>
        <Link href="/anpr" className="btn w-full sm:w-auto">
          <Icon name="camera" className="h-4 w-4" />
          Use ANPR camera instead
        </Link>
      </div>
      {gates.length === 0 && (
        <p className="error">
          No active ENTRY gate. <Link href="/gates" className="underline">Add one</Link> first.
        </p>
      )}
      {slots.length === 0 && (
        <p className="error">
          No available slots right now. Check the <Link href="/slots" className="underline">slot board</Link>.
        </p>
      )}
      <EntryForm
        gates={gates}
        slots={slots}
        vehicleTypes={vehicleTypes}
        knownVehicles={vehicles.map((v) => v.registration_no)}
      />
    </div>
  );
}

import { Suspense } from "react";
import Link from "next/link";
import { query } from "@/lib/db";
import { Icon } from "@/components/Icon";
import { SlotBoardView, type SlotItem } from "./SlotBoardView";

export default function SlotBoard() {
  return (
    <Suspense fallback={<p className="text-muted">Loading slot board…</p>}>
      <SlotBoardContent />
    </Suspense>
  );
}

async function SlotBoardContent() {
  const slots = await query<SlotItem>(
    `SELECT s.slot_id, s.slot_no, s.zone_id, z.zone_name, z.floor_level, st.slot_type_name, s.availability_status,
            t.ticket_no, to_char(t.entry_time, 'YYYY-MM-DD HH24:MI') as entry_time,
            to_char(LOCALTIMESTAMP - t.entry_time, 'FMDD"d" HH24"h" MI"m"') AS duration,
            v.registration_no, vt.type_name as vehicle_type
       FROM parking_slot s
       JOIN parking_zone z ON z.zone_id = s.zone_id
       JOIN slot_type st ON st.slot_type_id = s.slot_type_id
       LEFT JOIN parking_ticket t ON t.slot_id = s.slot_id AND t.ticket_status = 'ACTIVE'
       LEFT JOIN vehicle v ON v.vehicle_id = t.vehicle_id
       LEFT JOIN vehicle_type vt ON vt.type_id = v.type_id
      ORDER BY z.floor_level, z.zone_name, s.slot_no`,
  );

  return (
    <div className="space-y-5 sm:space-y-6">
      <div className="animate-reveal flex items-end justify-between gap-3">
        <div>
          <h1 className="page-title">Parking Slot Board</h1>
          <p className="page-subtitle">Interactive 2.5D visual layout with live vehicle status</p>
        </div>
        <div className="flex items-center gap-2">
          <Link href="/entry" className="btn-primary">
            <Icon name="plus" className="h-4 w-4" />
            New Entry
          </Link>
          <Link href="/slots/manage" className="btn">
            <Icon name="wrench" className="h-4 w-4" />
            Manage
          </Link>
        </div>
      </div>

      <SlotBoardView initialSlots={slots} />
    </div>
  );
}

"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import { Icon } from "@/components/Icon";
import { LicensePlate } from "@/components/LicensePlate";
import { VehicleBadge } from "@/components/VehicleBadge";
import { setSlotStatus } from "./actions";

export type SlotItem = {
  slot_id: number;
  slot_no: string;
  zone_id: number;
  zone_name: string;
  floor_level: number;
  slot_type_name: string;
  availability_status: string;
  ticket_no: number | null;
  registration_no: string | null;
  vehicle_type: string | null;
  entry_time: string | null;
  duration: string | null;
};

const STATUS_ICONS = {
  AVAILABLE: "check",
  OCCUPIED: "car",
  MAINTENANCE: "wrench",
} as const;

export function SlotBoardView({ initialSlots }: { initialSlots: SlotItem[] }) {
  const [statusFilter, setStatusFilter] = useState<string>("ALL");
  const [selectedZone, setSelectedZone] = useState<string>("ALL");
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [viewMode, setViewMode] = useState<"bay" | "compact">("bay");

  // All unique zones
  const zoneList = useMemo(() => {
    const map = new Map<string, { id: number; name: string; floor: number }>();
    for (const s of initialSlots) {
      if (!map.has(s.zone_name)) {
        map.set(s.zone_name, { id: s.zone_id, name: s.zone_name, floor: s.floor_level });
      }
    }
    return Array.from(map.values()).sort((a, b) => a.floor - b.floor || a.name.localeCompare(b.name));
  }, [initialSlots]);

  // Status counts
  const counts = useMemo(() => {
    let available = 0;
    let occupied = 0;
    let maintenance = 0;
    for (const s of initialSlots) {
      if (s.availability_status === "AVAILABLE") available++;
      else if (s.availability_status === "OCCUPIED") occupied++;
      else if (s.availability_status === "MAINTENANCE") maintenance++;
    }
    return {
      ALL: initialSlots.length,
      AVAILABLE: available,
      OCCUPIED: occupied,
      MAINTENANCE: maintenance,
    };
  }, [initialSlots]);

  // Filtered slots
  const filteredSlots = useMemo(() => {
    const q = searchQuery.trim().toLowerCase();
    return initialSlots.filter((s) => {
      // Status check
      if (statusFilter !== "ALL" && s.availability_status !== statusFilter) return false;
      // Zone check
      if (selectedZone !== "ALL" && s.zone_name !== selectedZone) return false;
      // Search query check
      if (q) {
        const matchesSlot = s.slot_no.toLowerCase().includes(q);
        const matchesPlate = s.registration_no?.toLowerCase().includes(q);
        const matchesType = s.slot_type_name.toLowerCase().includes(q);
        if (!matchesSlot && !matchesPlate && !matchesType) return false;
      }
      return true;
    });
  }, [initialSlots, statusFilter, selectedZone, searchQuery]);

  // Group filtered by zone
  const groupedZones = useMemo(() => {
    const map = new Map<string, SlotItem[]>();
    for (const s of filteredSlots) {
      const list = map.get(s.zone_name) ?? [];
      list.push(s);
      map.set(s.zone_name, list);
    }
    return map;
  }, [filteredSlots]);

  return (
    <div className="space-y-5 sm:space-y-6">
      {/* Search & Filter Toolbar */}
      <div className="card space-y-4 p-4 sm:p-5">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
          {/* Accessible Tabs (Following Modern Web Guidance) */}
          <div
            role="tablist"
            aria-label="Filter parking slots by status"
            className="flex flex-wrap items-center gap-1.5 p-1 rounded-xl bg-surface-2 border border-border/80"
          >
            {[
              { id: "ALL", label: "All Slots", count: counts.ALL, color: "text-foreground" },
              { id: "AVAILABLE", label: "Available", count: counts.AVAILABLE, color: "text-emerald-600 dark:text-emerald-400" },
              { id: "OCCUPIED", label: "Occupied", count: counts.OCCUPIED, color: "text-rose-600 dark:text-rose-400" },
              { id: "MAINTENANCE", label: "Maintenance", count: counts.MAINTENANCE, color: "text-amber-600 dark:text-amber-400" },
            ].map((tab) => {
              const isSelected = statusFilter === tab.id;
              return (
                <button
                  key={tab.id}
                  type="button"
                  role="tab"
                  aria-selected={isSelected}
                  onClick={() => setStatusFilter(tab.id)}
                  className={`inline-flex items-center gap-2 rounded-lg px-3 py-1.5 text-xs font-semibold transition-all duration-150 relative ${
                    isSelected
                      ? "bg-surface text-foreground shadow-xs ring-1 ring-black/5 dark:ring-white/10"
                      : "text-muted hover:text-foreground hover:bg-surface/50"
                  }`}
                >
                  {tab.id !== "ALL" && (
                    <span
                      className={`h-2 w-2 rounded-full ${
                        tab.id === "AVAILABLE"
                          ? "bg-emerald-500 animate-pulse"
                          : tab.id === "OCCUPIED"
                          ? "bg-rose-500"
                          : "bg-amber-500"
                      }`}
                      aria-hidden="true"
                    />
                  )}
                  <span>{tab.label}</span>
                  <span className={`px-1.5 py-0.2 rounded-full text-[10px] tabular-nums bg-surface-2 ${tab.color}`}>
                    {tab.count}
                  </span>
                </button>
              );
            })}
          </div>

          {/* Quick Search & View Toggle */}
          <div className="flex flex-wrap items-center gap-2.5">
            <div className="relative flex-1 sm:w-64">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-muted pointer-events-none">
                <Icon name="tag" className="h-4 w-4" />
              </span>
              <input
                type="text"
                placeholder="Search slot (P-01) or plate..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="input pl-9 text-xs sm:text-xs min-h-9 h-9"
              />
              {searchQuery && (
                <button
                  type="button"
                  onClick={() => setSearchQuery("")}
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 text-xs text-muted hover:text-foreground"
                >
                  ✕
                </button>
              )}
            </div>

            {/* Zone Filter Dropdown */}
            <select
              value={selectedZone}
              onChange={(e) => setSelectedZone(e.target.value)}
              className="input text-xs sm:text-xs min-h-9 h-9 w-auto"
            >
              <option value="ALL">All Zones ({zoneList.length})</option>
              {zoneList.map((z) => (
                <option key={z.name} value={z.name}>
                  {z.name} (Floor {z.floor})
                </option>
              ))}
            </select>

            {/* View Mode Toggle */}
            <div className="flex items-center rounded-lg border border-border p-0.5 bg-surface-2 text-xs">
              <button
                type="button"
                onClick={() => setViewMode("bay")}
                className={`p-1.5 rounded-md transition-colors ${
                  viewMode === "bay" ? "bg-surface shadow-2xs font-semibold text-accent" : "text-muted hover:text-foreground"
                }`}
                title="2.5D Parking Bay View"
              >
                <Icon name="grid" className="h-4 w-4" />
              </button>
              <button
                type="button"
                onClick={() => setViewMode("compact")}
                className={`p-1.5 rounded-md transition-colors ${
                  viewMode === "compact" ? "bg-surface shadow-2xs font-semibold text-accent" : "text-muted hover:text-foreground"
                }`}
                title="Compact Tiles"
              >
                <Icon name="shapes" className="h-4 w-4" />
              </button>
            </div>
          </div>
        </div>

        {/* Results Count Banner */}
        <div className="flex items-center justify-between text-xs text-muted pt-2 border-t border-border/50">
          <span>
            Showing <strong className="text-foreground tabular-nums">{filteredSlots.length}</strong> of {initialSlots.length} slots
          </span>
          {searchQuery && (
            <span className="text-accent font-medium">Filtered by: &ldquo;{searchQuery}&rdquo;</span>
          )}
        </div>
      </div>

      {/* Zero Results State */}
      {filteredSlots.length === 0 && (
        <div className="card text-center py-12 space-y-3">
          <span className="grid h-12 w-12 mx-auto place-items-center rounded-full bg-surface-2 text-muted">
            <Icon name="grid" className="h-6 w-6" />
          </span>
          <p className="font-semibold text-foreground">No parking slots matched your filters</p>
          <p className="text-xs text-muted max-w-sm mx-auto">
            Try adjusting your search query, selecting another zone, or resetting the status filter.
          </p>
          <button
            type="button"
            onClick={() => {
              setStatusFilter("ALL");
              setSelectedZone("ALL");
              setSearchQuery("");
            }}
            className="btn text-xs mx-auto"
          >
            Reset Filters
          </button>
        </div>
      )}

      {/* Grouped Zones List */}
      {[...groupedZones].map(([zone, zoneSlots], zoneIdx) => {
        const freeCount = zoneSlots.filter((s) => s.availability_status === "AVAILABLE").length;
        const totalZone = zoneSlots.length;
        const pctFree = totalZone ? Math.round((freeCount / totalZone) * 100) : 0;

        return (
          <section
            key={zone}
            className="card animate-reveal space-y-4"
            style={{ animationDelay: `${zoneIdx * 60}ms` }}
          >
            <div className="flex flex-wrap items-center justify-between gap-3 border-b border-border/60 pb-3">
              <div>
                <h2 className="font-bold text-base flex items-center gap-2">
                  <span>{zone}</span>
                  <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-surface-2 text-muted">
                    Floor {zoneSlots[0]?.floor_level ?? 0}
                  </span>
                </h2>
                <p className="text-xs text-muted mt-0.5">
                  {freeCount} of {totalZone} slots currently available ({pctFree}% vacant)
                </p>
              </div>

              {/* Mini capacity bar in header */}
              <div className="flex items-center gap-3">
                <div className="w-24 sm:w-32 h-2 rounded-full bg-surface-2 overflow-hidden ring-1 ring-black/5 dark:ring-white/5">
                  <div
                    className="h-full bg-rose-500 transition-all duration-300"
                    style={{ width: `${100 - pctFree}%` }}
                  />
                </div>
                <span className="text-xs font-bold tabular-nums text-foreground">
                  {totalZone - freeCount}/{totalZone}
                </span>
              </div>
            </div>

            {/* Parking Stalls Grid */}
            <div
              className={`grid gap-3 ${
                viewMode === "bay"
                  ? "grid-cols-1 min-[440px]:grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6"
                  : "grid-cols-2 min-[440px]:grid-cols-3 sm:grid-cols-4 lg:grid-cols-8 text-xs"
              }`}
            >
              {zoneSlots.map((s) => {
                const isOccupied = s.availability_status === "OCCUPIED";
                const isAvailable = s.availability_status === "AVAILABLE";
                const isMaintenance = s.availability_status === "MAINTENANCE";

                if (viewMode === "compact") {
                  return (
                    <div
                      key={s.slot_id}
                      className={`flex flex-col rounded-lg border p-2.5 transition-all duration-150 hover:-translate-y-0.5 hover:shadow-xs ${
                        isAvailable
                          ? "border-emerald-500/30 bg-emerald-500/[0.04]"
                          : isOccupied
                          ? "border-rose-500/30 bg-rose-500/[0.04]"
                          : "border-amber-500/30 bg-amber-500/[0.04]"
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <span className="font-bold">{s.slot_no}</span>
                        <span
                          className={`h-2 w-2 rounded-full ${
                            isAvailable
                              ? "bg-emerald-500 animate-pulse"
                              : isOccupied
                              ? "bg-rose-500"
                              : "bg-amber-500"
                          }`}
                        />
                      </div>
                      <div className="truncate text-[10px] text-muted mt-0.5">{s.slot_type_name}</div>
                      <div className="mt-2 pt-1 border-t border-border/40">
                        {isOccupied && s.ticket_no && s.registration_no ? (
                          <Link
                            href={`/exit/${s.ticket_no}`}
                            className="font-mono text-[11px] font-bold text-accent truncate hover:underline block"
                          >
                            {s.registration_no}
                          </Link>
                        ) : (
                          <span className="text-[10px] text-muted">{s.availability_status.toLowerCase()}</span>
                        )}
                      </div>
                    </div>
                  );
                }

                // 2.5D Architectural Parking Stall Bay
                return (
                  <div
                    key={s.slot_id}
                    className={`group relative flex flex-col rounded-xl border-x-2 border-y border-dashed p-3 transition-all duration-200 ease-out hover:-translate-y-1 hover:shadow-md ${
                      isAvailable
                        ? "border-x-emerald-500/50 border-y-emerald-500/20 bg-emerald-500/[0.04] hover:bg-emerald-500/[0.08]"
                        : isOccupied
                        ? "border-x-rose-500/50 border-y-rose-500/20 bg-rose-500/[0.04] hover:bg-rose-500/[0.08]"
                        : "border-x-amber-500/50 border-y-amber-500/20 bg-amber-500/[0.04] hover:bg-amber-500/[0.08]"
                    }`}
                  >
                    {/* Parking Curb Stop Bar (Pavement aesthetic) */}
                    <div className="h-1 w-3/4 mx-auto rounded-full bg-slate-300 dark:bg-slate-700/80 mb-2 opacity-80" />

                    {/* Stencil Bay Number & Status Dot */}
                    <div className="flex items-center justify-between gap-1">
                      <span className="font-mono font-black text-sm tracking-tight text-foreground/90">
                        {s.slot_no}
                      </span>
                      <span
                        className={`inline-flex items-center gap-1 rounded-full px-1.5 py-0.5 text-[10px] font-bold ${
                          isAvailable
                            ? "bg-emerald-500/15 text-emerald-700 dark:text-emerald-400"
                            : isOccupied
                            ? "bg-rose-500/15 text-rose-700 dark:text-rose-400"
                            : "bg-amber-500/15 text-amber-700 dark:text-amber-400"
                        }`}
                      >
                        <span
                          className={`h-1.5 w-1.5 rounded-full ${
                            isAvailable
                              ? "bg-emerald-500 animate-pulse"
                              : isOccupied
                              ? "bg-rose-500"
                              : "bg-amber-500"
                          }`}
                        />
                        {isAvailable ? "OPEN" : isOccupied ? "PARKED" : "HOLD"}
                      </span>
                    </div>

                    <div className="text-[11px] text-muted truncate mt-0.5">{s.slot_type_name}</div>

                    {/* Stall Content (Parked Car vs Vacant Bay) */}
                    <div className="my-2.5 flex-1 flex flex-col justify-center">
                      {isOccupied && s.registration_no ? (
                        <div className="space-y-1.5">
                          {/* Authentic License Plate */}
                          <div className="flex justify-center">
                            <LicensePlate plate={s.registration_no} ticketNo={s.ticket_no} size="sm" />
                          </div>

                          {/* Vehicle Type & Elapsed Duration */}
                          <div className="flex items-center justify-between text-[10px] text-muted pt-1">
                            {s.vehicle_type && <span className="truncate">{s.vehicle_type}</span>}
                            {s.duration && (
                              <span className="tabular-nums font-semibold text-rose-600 dark:text-rose-400 ml-auto">
                                ⏱ {s.duration}
                              </span>
                            )}
                          </div>
                        </div>
                      ) : isAvailable ? (
                        <div className="text-center py-2 space-y-1">
                          <span className="inline-block text-xs font-mono font-bold text-emerald-600 dark:text-emerald-400">
                            🅿️ VACANT
                          </span>
                          <p className="text-[10px] text-muted">Ready for check-in</p>
                        </div>
                      ) : (
                        <div className="text-center py-2 text-amber-600 dark:text-amber-400">
                          <Icon name="wrench" className="h-4 w-4 mx-auto mb-1" />
                          <span className="text-[10px] font-semibold">Under Service</span>
                        </div>
                      )}
                    </div>

                    {/* Quick Stall Actions */}
                    <div className="pt-2 border-t border-border/50 text-xs">
                      {isOccupied && s.ticket_no ? (
                        <Link
                          href={`/exit/${s.ticket_no}`}
                          className="btn-primary w-full text-xs h-8 min-h-8 py-1 justify-between shadow-2xs"
                        >
                          <span>Process Exit</span>
                          <Icon name="exit" className="h-3.5 w-3.5" />
                        </Link>
                      ) : isAvailable ? (
                        <div className="flex items-center gap-1.5">
                          <Link
                            href={`/entry`}
                            className="btn w-full text-xs h-7 min-h-7 py-0.5 justify-center font-medium"
                          >
                            + Park Car
                          </Link>
                          <form action={setSlotStatus.bind(null, s.slot_id, "MAINTENANCE")}>
                            <button
                              type="submit"
                              className="btn text-xs h-7 min-h-7 px-2 text-muted hover:text-amber-600"
                              title="Set Maintenance"
                            >
                              <Icon name="wrench" className="h-3.5 w-3.5" />
                            </button>
                          </form>
                        </div>
                      ) : (
                        <form action={setSlotStatus.bind(null, s.slot_id, "AVAILABLE")}>
                          <button
                            type="submit"
                            className="btn w-full text-xs h-7 min-h-7 py-0.5 justify-center text-emerald-600 dark:text-emerald-400 font-medium"
                          >
                            Mark Available
                          </button>
                        </form>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </section>
        );
      })}
    </div>
  );
}

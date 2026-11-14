"use client";

import Link from "next/link";
import { useActionState, useState } from "react";
import { parkVehicle, type EntryState } from "./actions";
import { formatPlateAsYouType } from "@/lib/anpr";

type Option = { value: number; label: string };

export function EntryForm({
  gates,
  slots,
  vehicleTypes,
  knownVehicles,
}: {
  gates: Option[];
  slots: Option[];
  vehicleTypes: Option[];
  knownVehicles: string[];
}) {
  const [state, action, pending] = useActionState<EntryState, FormData>(parkVehicle, { error: null });
  const [regNo, setRegNo] = useState("");

  return (
    <form action={action} className="card max-w-2xl space-y-5">
      <label className="block">
        <span className="label">Registration no. *</span>
        <input
          name="registration_no"
          required
          list="known-vehicles"
          value={regNo}
          onChange={(e) => setRegNo(formatPlateAsYouType(e.target.value))}
          className="input font-mono text-lg tracking-wider uppercase sm:text-base"
          placeholder="e.g. DL-1C-AA-1111, GJ-01-AB-1234"
          maxLength={16}
          autoCapitalize="characters"
          autoComplete="off"
        />
        <datalist id="known-vehicles">
          {knownVehicles.map((r) => (
            <option key={r} value={r} />
          ))}
        </datalist>
      </label>

      <div className="grid gap-3 sm:grid-cols-2">
        <label className="block">
          <span className="label">Entry gate *</span>
          <select name="entry_gate_id" required className="input">
            {gates.map((g) => (
              <option key={g.value} value={g.value}>
                {g.label}
              </option>
            ))}
          </select>
        </label>
        <label className="block">
          <span className="label">Slot</span>
          <select name="slot_id" className="input">
            <option value="">Auto-assign ({slots.length} free)</option>
            {slots.map((s) => (
              <option key={s.value} value={s.value}>
                {s.label}
              </option>
            ))}
          </select>
        </label>
      </div>

      <fieldset className="rounded-lg border border-dashed border-border p-4">
        <legend className="px-1 text-sm text-muted">Only needed for a vehicle not seen before</legend>
        <div className="grid gap-3 sm:grid-cols-3">
          <label className="block">
            <span className="label">Vehicle type</span>
            <select name="type_id" className="input">
              <option value="">—</option>
              {vehicleTypes.map((t) => (
                <option key={t.value} value={t.value}>
                  {t.label}
                </option>
              ))}
            </select>
          </label>
          <label className="block">
            <span className="label">Owner name</span>
            <input name="owner_name" className="input" />
          </label>
          <label className="block">
            <span className="label">Owner phone</span>
            <input name="owner_phone" type="tel" inputMode="tel" className="input" />
          </label>
        </div>
      </fieldset>

      {state.error && <p className="error">{state.error}</p>}
      {state.message && (
        <p className="success">
          {state.message}{" "}
          <Link href="/tickets" className="underline">
            View active tickets
          </Link>
        </p>
      )}

      <button className="btn-primary min-h-12 w-full text-base sm:w-auto sm:text-sm" disabled={pending || gates.length === 0}>
        {pending ? "Issuing…" : "Issue ticket"}
      </button>
    </form>
  );
}

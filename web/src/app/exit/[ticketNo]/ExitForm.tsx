"use client";

import { useActionState } from "react";
import { PAYMENT_MODE } from "@/lib/enums";
import { processExit, type ExitState } from "./actions";

export function ExitForm({
  ticketNo,
  amount,
  gates,
}: {
  ticketNo: number;
  amount: number;
  gates: { value: number; label: string }[];
}) {
  const [state, action, pending] = useActionState<ExitState, FormData>(processExit.bind(null, ticketNo), {
    error: null,
  });

  return (
    <form action={action} className="card space-y-4">
      <div className="grid gap-3 sm:grid-cols-2">
        <label className="block">
          <span className="label">Exit gate *</span>
          <select name="exit_gate_id" required className="input">
            {gates.map((g) => (
              <option key={g.value} value={g.value}>
                {g.label}
              </option>
            ))}
          </select>
        </label>
        <label className="block">
          <span className="label">Payment mode *</span>
          <select name="payment_mode" required className="input">
            {PAYMENT_MODE.map((m) => (
              <option key={m}>{m}</option>
            ))}
          </select>
        </label>
      </div>
      {state.error && <p className="error">{state.error}</p>}
      <button className="btn-primary min-h-12 w-full text-base" disabled={pending || gates.length === 0}>
        {pending ? "Processing…" : `Collect ₹${amount.toFixed(2)} & close ticket`}
      </button>
    </form>
  );
}

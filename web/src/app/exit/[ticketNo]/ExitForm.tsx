"use client";

import { useActionState, useState } from "react";
import { PAYMENT_MODE } from "@/lib/enums";
import { Icon } from "@/components/Icon";
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
  const [selectedMode, setSelectedMode] = useState<string>("UPI");
  const [state, action, pending] = useActionState<ExitState, FormData>(
    processExit.bind(null, ticketNo),
    { error: null }
  );

  return (
    <form action={action} className="card space-y-4">
      {/* Hidden input to pass selected payment mode to server action */}
      <input type="hidden" name="payment_mode" value={selectedMode} />

      <div className="space-y-3">
        <label className="block">
          <span className="label">Exit Gate *</span>
          <select name="exit_gate_id" required className="input font-medium">
            {gates.map((g) => (
              <option key={g.value} value={g.value}>
                {g.label}
              </option>
            ))}
          </select>
        </label>

        <div>
          <span className="label">Payment Mode *</span>
          <div role="radiogroup" aria-label="Payment Mode" className="grid grid-cols-3 gap-2">
            {[
              { id: "UPI", label: "UPI / QR", icon: "card" },
              { id: "CASH", label: "Cash", icon: "rupee" },
              { id: "CARD", label: "Card", icon: "card" },
            ].map((m) => {
              const isSelected = selectedMode === m.id;
              return (
                <button
                  key={m.id}
                  type="button"
                  role="radio"
                  aria-checked={isSelected}
                  onClick={() => setSelectedMode(m.id)}
                  className={`flex flex-col items-center justify-center gap-1.5 rounded-xl border p-2.5 text-xs font-semibold transition-all duration-150 active:scale-95 ${
                    isSelected
                      ? "border-accent bg-accent/10 text-accent ring-2 ring-accent/30 shadow-xs"
                      : "border-border bg-surface hover:bg-surface-2 text-muted hover:text-foreground"
                  }`}
                >
                  <Icon name={m.icon as any} className="h-4 w-4" />
                  <span>{m.label}</span>
                </button>
              );
            })}
          </div>
        </div>
      </div>

      {state.error && <p className="error">{state.error}</p>}

      <div className="flex flex-col sm:flex-row gap-2.5 pt-2">
        <button
          type="button"
          onClick={() => window.print()}
          className="btn flex-1 text-sm no-print"
        >
          <Icon name="clipboard" className="h-4 w-4" />
          Print Receipt Slip
        </button>
        <button
          type="submit"
          disabled={pending || gates.length === 0}
          className="btn-primary flex-1 min-h-11 text-sm font-bold shadow-md shadow-accent/20"
        >
          {pending ? "Processing Payment…" : `Confirm ₹${amount.toFixed(2)} & Exit`}
        </button>
      </div>
    </form>
  );
}

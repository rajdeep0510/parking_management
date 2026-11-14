"use client";

import { useActionState, useState, useMemo } from "react";
import { loginAction, type LoginState } from "./actions";
import { Icon } from "@/components/Icon";
import type { GateItem } from "./page";

export function LoginForm({ gates = [] }: { gates?: GateItem[] }) {
  const [state, formAction, isPending] = useActionState<LoginState, FormData>(
    loginAction,
    {}
  );

  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [gateMode, setGateMode] = useState<"ENTRY" | "EXIT">("ENTRY");
  const [selectedGateId, setSelectedGateId] = useState<number | "">("");

  const entryGates = useMemo(
    () => gates.filter((g) => g.gate_type === "ENTRY"),
    [gates]
  );
  const exitGates = useMemo(
    () => gates.filter((g) => g.gate_type === "EXIT"),
    [gates]
  );

  const availableGates = gateMode === "ENTRY" ? entryGates : exitGates;

  const isGateRole =
    username.toLowerCase().includes("gate") ||
    username.toLowerCase().includes("alex") ||
    username.toLowerCase().includes("amit") ||
    username.toLowerCase().includes("rohit");

  const applyCredentials = (
    u: string,
    p: string,
    mode?: "ENTRY" | "EXIT",
    gateId?: number
  ) => {
    setUsername(u);
    setPassword(p);
    if (mode) {
      setGateMode(mode);
      if (gateId) {
        setSelectedGateId(gateId);
      } else {
        const matching = (mode === "ENTRY" ? entryGates : exitGates)[0];
        setSelectedGateId(matching ? matching.gate_id : "");
      }
    }
  };

  const selectedGateName =
    availableGates.find((g) => g.gate_id === Number(selectedGateId))?.gate_number || "";

  return (
    <div className="space-y-8">
      {/* Login Card */}
      <div className="rounded-2xl border border-border bg-surface p-6 sm:p-8 shadow-sm">
        <form action={formAction} className="space-y-5">
          {state.error && (
            <div className="rounded-xl border border-rose-500/20 bg-rose-500/10 px-4 py-3 text-sm text-rose-600 dark:text-rose-400">
              {state.error}
            </div>
          )}

          <div>
            <label
              htmlFor="username"
              className="block text-xs font-semibold uppercase tracking-wider text-muted mb-2"
            >
              Username / Login ID
            </label>
            <input
              id="username"
              name="username"
              type="text"
              required
              autoFocus
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="e.g. gate_worker or supervisor"
              className="w-full rounded-xl border border-border bg-surface-2 px-4 py-2.5 text-foreground placeholder:text-muted focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent"
            />
          </div>

          <div>
            <label
              htmlFor="password"
              className="block text-xs font-semibold uppercase tracking-wider text-muted mb-2"
            >
              Password
            </label>
            <input
              id="password"
              name="password"
              type="password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              className="w-full rounded-xl border border-border bg-surface-2 px-4 py-2.5 text-foreground placeholder:text-muted focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent"
            />
          </div>

          {/* Gate Station Selection (Visible for gate operators or togglable) */}
          <div className="rounded-xl border border-border/80 bg-surface-2/40 p-4 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold uppercase tracking-wider text-muted flex items-center gap-1.5">
                <Icon name="gate" className="h-4 w-4" />
                Gate Station Assignment
              </span>
              {isGateRole && (
                <span className="text-[11px] font-semibold text-accent bg-accent-soft px-2 py-0.5 rounded-full">
                  Gate Operator Detected
                </span>
              )}
            </div>

            {/* Mode Tabs */}
            <div className="grid grid-cols-2 gap-2 p-1 rounded-xl bg-surface border border-border">
              <button
                type="button"
                onClick={() => {
                  setGateMode("ENTRY");
                  const first = entryGates[0];
                  if (first) setSelectedGateId(first.gate_id);
                }}
                className={`flex items-center justify-center gap-2 rounded-lg py-2 text-xs font-semibold transition ${
                  gateMode === "ENTRY"
                    ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400 border border-emerald-500/30 shadow-xs"
                    : "text-muted hover:text-foreground"
                }`}
              >
                <span className="h-2 w-2 rounded-full bg-emerald-500" />
                ENTRY GATE (Fills Slot)
              </button>
              <button
                type="button"
                onClick={() => {
                  setGateMode("EXIT");
                  const first = exitGates[0];
                  if (first) setSelectedGateId(first.gate_id);
                }}
                className={`flex items-center justify-center gap-2 rounded-lg py-2 text-xs font-semibold transition ${
                  gateMode === "EXIT"
                    ? "bg-rose-500/15 text-rose-600 dark:text-rose-400 border border-rose-500/30 shadow-xs"
                    : "text-muted hover:text-foreground"
                }`}
              >
                <span className="h-2 w-2 rounded-full bg-rose-500" />
                EXIT GATE (Empties Slot)
              </button>
            </div>

            {/* Gate Dropdown */}
            {availableGates.length > 0 && (
              <div>
                <label className="block text-[11px] text-muted mb-1 font-medium">
                  Select Active {gateMode === "ENTRY" ? "Entry" : "Exit"} Gate:
                </label>
                <select
                  value={selectedGateId}
                  onChange={(e) => setSelectedGateId(Number(e.target.value))}
                  className="w-full rounded-lg border border-border bg-surface px-3 py-2 text-xs text-foreground focus:border-accent focus:outline-none"
                >
                  {availableGates.map((g) => (
                    <option key={g.gate_id} value={g.gate_id}>
                      {g.gate_number} — {g.zone_name}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Hidden Inputs for Form Submission */}
            <input type="hidden" name="gate_mode" value={gateMode} />
            <input
              type="hidden"
              name="gate_id"
              value={selectedGateId || (availableGates[0]?.gate_id ?? "")}
            />
            <input
              type="hidden"
              name="gate_name"
              value={selectedGateName || (availableGates[0]?.gate_number ?? "")}
            />
          </div>

          <button
            type="submit"
            disabled={isPending}
            className="w-full rounded-xl bg-accent px-4 py-3 font-semibold text-accent-fg transition-opacity hover:opacity-90 disabled:opacity-50 cursor-pointer"
          >
            {isPending
              ? "Signing in…"
              : isGateRole
              ? `Sign In to ${gateMode} Gate Terminal`
              : "Sign In"}
          </button>
        </form>
      </div>

      {/* Quick Demo Logins Section */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <h2 className="text-xs font-semibold uppercase tracking-wider text-muted">
            Quick One-Click Demo Credentials
          </h2>
          <span className="text-xs text-muted">Click any role to autofill</span>
        </div>

        <div className="grid gap-2.5 sm:grid-cols-2 lg:grid-cols-3">
          {/* Gate Worker ENTRY */}
          <button
            type="button"
            onClick={() =>
              applyCredentials(
                "gate_worker",
                "gate123",
                "ENTRY",
                entryGates[0]?.gate_id
              )
            }
            className="group flex flex-col justify-between rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-3.5 text-left transition hover:border-emerald-500 hover:bg-emerald-500/10 cursor-pointer"
          >
            <div className="flex items-center justify-between gap-2 mb-2">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-emerald-500/20 bg-emerald-500/10 px-2 py-0.5 text-xs font-semibold text-emerald-600 dark:text-emerald-400">
                <Icon name="gate" className="h-3.5 w-3.5" />
                Gate Worker (ENTRY)
              </span>
              <span className="text-[11px] text-muted font-mono">gate123</span>
            </div>
            <p className="text-xs text-muted leading-snug">
              🟢 Inbound vehicles: Scan plate → <strong>fills parking slot (OCCUPIED)</strong>.
            </p>
          </button>

          {/* Gate Worker EXIT */}
          <button
            type="button"
            onClick={() =>
              applyCredentials(
                "gate_worker",
                "gate123",
                "EXIT",
                exitGates[0]?.gate_id
              )
            }
            className="group flex flex-col justify-between rounded-xl border border-rose-500/30 bg-rose-500/5 p-3.5 text-left transition hover:border-rose-500 hover:bg-rose-500/10 cursor-pointer"
          >
            <div className="flex items-center justify-between gap-2 mb-2">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-rose-500/20 bg-rose-500/10 px-2 py-0.5 text-xs font-semibold text-rose-600 dark:text-rose-400">
                <Icon name="gate" className="h-3.5 w-3.5" />
                Gate Worker (EXIT)
              </span>
              <span className="text-[11px] text-muted font-mono">gate123</span>
            </div>
            <p className="text-xs text-muted leading-snug">
              🔴 Outbound vehicles: Scan plate → <strong>empties parking slot (AVAILABLE)</strong>.
            </p>
          </button>

          {/* Supervisor */}
          <button
            type="button"
            onClick={() => applyCredentials("supervisor", "super123")}
            className="group flex flex-col justify-between rounded-xl border border-border bg-surface p-3.5 text-left transition hover:border-accent hover:bg-surface-2 cursor-pointer"
          >
            <div className="flex items-center justify-between gap-2 mb-2">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-blue-500/20 bg-blue-500/10 px-2 py-0.5 text-xs font-medium text-blue-600 dark:text-blue-400">
                <Icon name="clipboard" className="h-3.5 w-3.5" />
                Supervisor
              </span>
              <span className="text-[11px] text-muted font-mono">super123</span>
            </div>
            <p className="text-xs text-muted leading-snug">
              Rosters, facility shifts & zone management.
            </p>
          </button>

          {/* Cashier */}
          <button
            type="button"
            onClick={() => applyCredentials("cashier", "cash123")}
            className="group flex flex-col justify-between rounded-xl border border-border bg-surface p-3.5 text-left transition hover:border-accent hover:bg-surface-2 cursor-pointer"
          >
            <div className="flex items-center justify-between gap-2 mb-2">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-amber-500/20 bg-amber-500/10 px-2 py-0.5 text-xs font-medium text-amber-600 dark:text-amber-400">
                <Icon name="rupee" className="h-3.5 w-3.5" />
                Cashier
              </span>
              <span className="text-[11px] text-muted font-mono">cash123</span>
            </div>
            <p className="text-xs text-muted leading-snug">
              Payment desk, checkout & collections.
            </p>
          </button>

          {/* Security Guard */}
          <button
            type="button"
            onClick={() => applyCredentials("security", "sec123")}
            className="group flex flex-col justify-between rounded-xl border border-border bg-surface p-3.5 text-left transition hover:border-accent hover:bg-surface-2 cursor-pointer"
          >
            <div className="flex items-center justify-between gap-2 mb-2">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-purple-500/20 bg-purple-500/10 px-2 py-0.5 text-xs font-medium text-purple-600 dark:text-purple-400">
                <Icon name="camera" className="h-3.5 w-3.5" />
                Security Guard
              </span>
              <span className="text-[11px] text-muted font-mono">sec123</span>
            </div>
            <p className="text-xs text-muted leading-snug">
              Surveillance & live ANPR monitoring.
            </p>
          </button>

          {/* Admin */}
          <button
            type="button"
            onClick={() => applyCredentials("admin", "admin123")}
            className="group flex flex-col justify-between rounded-xl border border-border bg-surface p-3.5 text-left transition hover:border-accent hover:bg-surface-2 cursor-pointer"
          >
            <div className="flex items-center justify-between gap-2 mb-2">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-rose-500/20 bg-rose-500/10 px-2 py-0.5 text-xs font-medium text-rose-600 dark:text-rose-400">
                <Icon name="home" className="h-3.5 w-3.5" />
                System Admin
              </span>
              <span className="text-[11px] text-muted font-mono">admin123</span>
            </div>
            <p className="text-xs text-muted leading-snug">
              Full database, tariffs & member control.
            </p>
          </button>
        </div>
      </div>
    </div>
  );
}

"use client";

import { useActionState, useState, useMemo, useTransition } from "react";
import { loginAction, directRoleLoginAction, type LoginState } from "./actions";
import { Icon } from "@/components/Icon";
import type { GateItem } from "./page";
import Link from "next/link";

export function LoginForm({ gates = [] }: { gates?: GateItem[] }) {
  const [state, formAction, isPending] = useActionState<LoginState, FormData>(
    loginAction,
    {}
  );

  const [isPendingRole, startTransition] = useTransition();
  const [activeRoleKey, setActiveRoleKey] = useState<string | null>(null);

  const [showManualForm, setShowManualForm] = useState(false);
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

  const handleDirectLogin = (roleKey: string) => {
    setActiveRoleKey(roleKey);
    startTransition(async () => {
      await directRoleLoginAction(roleKey);
    });
  };

  const selectedGateName =
    availableGates.find((g) => g.gate_id === Number(selectedGateId))?.gate_number || "";

  return (
    <div className="space-y-8">
      {/* 1-Click Academic Evaluation / Viva Quick Logins */}
      <div className="rounded-2xl border border-accent/20 bg-accent-soft/20 p-5 sm:p-7 shadow-xs">
        <div className="flex flex-wrap items-center justify-between gap-2 mb-4">
          <div>
            <div className="flex items-center gap-2">
              <span className="grid h-6 w-6 place-items-center rounded-md bg-accent text-accent-fg text-xs font-bold">
                ⚡
              </span>
              <h2 className="text-sm font-semibold uppercase tracking-wider text-foreground">
                1-Click Instant Role Logins
              </h2>
            </div>
            <p className="text-xs text-muted mt-0.5">
              Optimized for college vivas and presentations — click any role to launch immediately without passwords.
            </p>
          </div>
          <button
            type="button"
            onClick={() => handleDirectLogin("guest")}
            disabled={isPendingRole}
            className="inline-flex items-center gap-1.5 rounded-lg border border-border bg-surface px-3 py-1.5 text-xs font-medium text-foreground transition hover:border-accent hover:bg-surface-2 cursor-pointer disabled:opacity-50"
          >
            {isPendingRole && activeRoleKey === "guest" ? (
              <span className="h-3 w-3 animate-spin rounded-full border-2 border-accent border-t-transparent" />
            ) : (
              <Icon name="users" className="h-3.5 w-3.5 text-accent" />
            )}
            Guest / Evaluator Mode
          </button>
        </div>

        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {/* Gate Worker ENTRY */}
          <button
            type="button"
            onClick={() => handleDirectLogin("gate_entry")}
            disabled={isPendingRole}
            className={`group relative flex flex-col justify-between rounded-xl border p-4 text-left transition cursor-pointer disabled:opacity-50 ${
              activeRoleKey === "gate_entry" && isPendingRole
                ? "border-emerald-500 bg-emerald-500/15"
                : "border-emerald-500/30 bg-surface hover:border-emerald-500 hover:bg-emerald-500/5 shadow-xs"
            }`}
          >
            <div className="flex items-center justify-between gap-2 mb-2 w-full">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-emerald-500/20 bg-emerald-500/10 px-2 py-0.5 text-xs font-semibold text-emerald-600 dark:text-emerald-400">
                <Icon name="gate" className="h-3.5 w-3.5" />
                Gate Worker (ENTRY)
              </span>
              <span className="text-[11px] font-semibold text-emerald-600 dark:text-emerald-400 bg-emerald-500/10 px-1.5 py-0.2 rounded">
                Fills Slots
              </span>
            </div>
            <p className="text-xs text-muted leading-relaxed">
              Opens <strong>Live Camera ANPR</strong> at Entry Gate G-101. Allocates vacant slot to vehicle.
            </p>
            <div className="mt-3 flex items-center justify-between text-[11px] font-semibold text-emerald-600 dark:text-emerald-400">
              <span>{activeRoleKey === "gate_entry" && isPendingRole ? "Opening terminal…" : "Launch Entry Terminal →"}</span>
            </div>
          </button>

          {/* Gate Worker EXIT */}
          <button
            type="button"
            onClick={() => handleDirectLogin("gate_exit")}
            disabled={isPendingRole}
            className={`group relative flex flex-col justify-between rounded-xl border p-4 text-left transition cursor-pointer disabled:opacity-50 ${
              activeRoleKey === "gate_exit" && isPendingRole
                ? "border-rose-500 bg-rose-500/15"
                : "border-rose-500/30 bg-surface hover:border-rose-500 hover:bg-rose-500/5 shadow-xs"
            }`}
          >
            <div className="flex items-center justify-between gap-2 mb-2 w-full">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-rose-500/20 bg-rose-500/10 px-2 py-0.5 text-xs font-semibold text-rose-600 dark:text-rose-400">
                <Icon name="gate" className="h-3.5 w-3.5" />
                Gate Worker (EXIT)
              </span>
              <span className="text-[11px] font-semibold text-rose-600 dark:text-rose-400 bg-rose-500/10 px-1.5 py-0.2 rounded">
                Frees Slots
              </span>
            </div>
            <p className="text-xs text-muted leading-relaxed">
              Exit ANPR camera. Calculates stay duration, verifies payment & returns slot to AVAILABLE.
            </p>
            <div className="mt-3 flex items-center justify-between text-[11px] font-semibold text-rose-600 dark:text-rose-400">
              <span>{activeRoleKey === "gate_exit" && isPendingRole ? "Opening terminal…" : "Launch Exit Terminal →"}</span>
            </div>
          </button>

          {/* System Admin */}
          <button
            type="button"
            onClick={() => handleDirectLogin("admin")}
            disabled={isPendingRole}
            className={`group relative flex flex-col justify-between rounded-xl border p-4 text-left transition cursor-pointer disabled:opacity-50 ${
              activeRoleKey === "admin" && isPendingRole
                ? "border-accent bg-accent-soft"
                : "border-border bg-surface hover:border-accent hover:bg-surface-2 shadow-xs"
            }`}
          >
            <div className="flex items-center justify-between gap-2 mb-2 w-full">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-accent/20 bg-accent-soft px-2 py-0.5 text-xs font-semibold text-accent">
                <Icon name="home" className="h-3.5 w-3.5" />
                System Administrator
              </span>
              <span className="text-[11px] text-muted font-mono">admin</span>
            </div>
            <p className="text-xs text-muted leading-relaxed">
              Full DBMS management: 320 slots, zones, dynamic tariffs, member passes & shifts.
            </p>
            <div className="mt-3 flex items-center justify-between text-[11px] font-semibold text-accent">
              <span>{activeRoleKey === "admin" && isPendingRole ? "Signing in…" : "Open Operations Dashboard →"}</span>
            </div>
          </button>

          {/* Operations Supervisor */}
          <button
            type="button"
            onClick={() => handleDirectLogin("supervisor")}
            disabled={isPendingRole}
            className={`group relative flex flex-col justify-between rounded-xl border p-4 text-left transition cursor-pointer disabled:opacity-50 ${
              activeRoleKey === "supervisor" && isPendingRole
                ? "border-blue-500 bg-blue-500/15"
                : "border-border bg-surface hover:border-blue-500 hover:bg-surface-2 shadow-xs"
            }`}
          >
            <div className="flex items-center justify-between gap-2 mb-2 w-full">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-blue-500/20 bg-blue-500/10 px-2 py-0.5 text-xs font-medium text-blue-600 dark:text-blue-400">
                <Icon name="clipboard" className="h-3.5 w-3.5" />
                Operations Supervisor
              </span>
              <span className="text-[11px] text-muted font-mono">supervisor</span>
            </div>
            <p className="text-xs text-muted leading-relaxed">
              Floor occupancy oversight, staff shifts, capacity alarms & zone maintenance.
            </p>
            <div className="mt-3 flex items-center justify-between text-[11px] font-semibold text-blue-600 dark:text-blue-400">
              <span>{activeRoleKey === "supervisor" && isPendingRole ? "Signing in…" : "Launch Supervisor Portal →"}</span>
            </div>
          </button>

          {/* Cashier */}
          <button
            type="button"
            onClick={() => handleDirectLogin("cashier")}
            disabled={isPendingRole}
            className={`group relative flex flex-col justify-between rounded-xl border p-4 text-left transition cursor-pointer disabled:opacity-50 ${
              activeRoleKey === "cashier" && isPendingRole
                ? "border-amber-500 bg-amber-500/15"
                : "border-border bg-surface hover:border-amber-500 hover:bg-surface-2 shadow-xs"
            }`}
          >
            <div className="flex items-center justify-between gap-2 mb-2 w-full">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-amber-500/20 bg-amber-500/10 px-2 py-0.5 text-xs font-medium text-amber-600 dark:text-amber-400">
                <Icon name="rupee" className="h-3.5 w-3.5" />
                Cashier & Billing Desk
              </span>
              <span className="text-[11px] text-muted font-mono">cashier</span>
            </div>
            <p className="text-xs text-muted leading-relaxed">
              Active ticket processing, cash/UPI payment collection, and duration billing receipts.
            </p>
            <div className="mt-3 flex items-center justify-between text-[11px] font-semibold text-amber-600 dark:text-amber-400">
              <span>{activeRoleKey === "cashier" && isPendingRole ? "Signing in…" : "Launch Billing Desk →"}</span>
            </div>
          </button>

          {/* Security Guard */}
          <button
            type="button"
            onClick={() => handleDirectLogin("security")}
            disabled={isPendingRole}
            className={`group relative flex flex-col justify-between rounded-xl border p-4 text-left transition cursor-pointer disabled:opacity-50 ${
              activeRoleKey === "security" && isPendingRole
                ? "border-purple-500 bg-purple-500/15"
                : "border-border bg-surface hover:border-purple-500 hover:bg-surface-2 shadow-xs"
            }`}
          >
            <div className="flex items-center justify-between gap-2 mb-2 w-full">
              <span className="inline-flex items-center gap-1.5 rounded-md border border-purple-500/20 bg-purple-500/10 px-2 py-0.5 text-xs font-medium text-purple-600 dark:text-purple-400">
                <Icon name="camera" className="h-3.5 w-3.5" />
                Security Guard
              </span>
              <span className="text-[11px] text-muted font-mono">security</span>
            </div>
            <p className="text-xs text-muted leading-relaxed">
              Live ANPR feed monitoring, vehicle audit logs, and barrier status inspection.
            </p>
            <div className="mt-3 flex items-center justify-between text-[11px] font-semibold text-purple-600 dark:text-purple-400">
              <span>{activeRoleKey === "security" && isPendingRole ? "Signing in…" : "Launch Surveillance →"}</span>
            </div>
          </button>
        </div>
      </div>

      {/* Manual Password Login Collapsible Section */}
      <div className="rounded-2xl border border-border bg-surface p-5 sm:p-7 shadow-xs">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-xs font-semibold uppercase tracking-wider text-muted">
              Standard Database Login
            </h3>
            <p className="text-xs text-muted mt-0.5">
              Validate credentials against the <code className="font-mono">staff_account</code> table.
            </p>
          </div>
          <button
            type="button"
            onClick={() => setShowManualForm(!showManualForm)}
            className="text-xs font-medium text-accent hover:underline cursor-pointer"
          >
            {showManualForm ? "Hide Manual Form ↑" : "Show Manual Form ↓"}
          </button>
        </div>

        {showManualForm && (
          <form action={formAction} className="mt-5 space-y-4 border-t border-border pt-5">
            {state.error && (
              <div className="rounded-xl border border-rose-500/20 bg-rose-500/10 px-4 py-3 text-sm text-rose-600 dark:text-rose-400">
                {state.error}
              </div>
            )}

            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <label
                  htmlFor="username"
                  className="block text-xs font-semibold uppercase tracking-wider text-muted mb-2"
                >
                  Username
                </label>
                <input
                  id="username"
                  name="username"
                  type="text"
                  required
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  placeholder="e.g. admin or gate_worker"
                  className="w-full rounded-xl border border-border bg-surface-2 px-4 py-2.5 text-foreground placeholder:text-muted focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent text-sm"
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
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="•••••••• (or leave empty for demo)"
                  className="w-full rounded-xl border border-border bg-surface-2 px-4 py-2.5 text-foreground placeholder:text-muted focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent text-sm"
                />
              </div>
            </div>

            {/* Gate Station Selection */}
            <div className="rounded-xl border border-border/80 bg-surface-2/40 p-4 space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-muted flex items-center gap-1.5">
                  <Icon name="gate" className="h-4 w-4" />
                  Terminal Station Assignment
                </span>
              </div>

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
                  ENTRY GATE
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
                  EXIT GATE
                </button>
              </div>

              {availableGates.length > 0 && (
                <div>
                  <label className="block text-[11px] text-muted mb-1 font-medium">
                    Gate Station:
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
              className="w-full rounded-xl bg-accent px-4 py-2.5 font-semibold text-accent-fg transition-opacity hover:opacity-90 disabled:opacity-50 cursor-pointer text-sm"
            >
              {isPending ? "Validating & Signing In…" : "Sign In with Credentials"}
            </button>
          </form>
        )}
      </div>

      {/* Back to Project Landing Page */}
      <div className="flex items-center justify-center gap-4 text-xs text-muted">
        <Link href="/" className="hover:text-foreground inline-flex items-center gap-1.5">
          <Icon name="arrowLeft" className="h-3.5 w-3.5" />
          Back to Project Landing Page
        </Link>
        <span>•</span>
        <Link href="/dashboard" className="hover:text-foreground inline-flex items-center gap-1.5">
          <Icon name="home" className="h-3.5 w-3.5" />
          Direct to Operations Dashboard
        </Link>
      </div>
    </div>
  );
}

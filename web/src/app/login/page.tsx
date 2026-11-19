import { Suspense } from "react";
import type { Metadata } from "next";
import { getCurrentUser } from "@/lib/auth";
import { query } from "@/lib/db";
import { LoginForm } from "./LoginForm";
import Link from "next/link";
import { Icon } from "@/components/Icon";
import { logoutAction } from "./actions";

export const metadata: Metadata = {
  title: "Sign In — SmartPark Management",
  description: "Frictionless authentication & role selection for parking operations.",
};

export type GateItem = {
  gate_id: number;
  gate_number: string;
  gate_type: "ENTRY" | "EXIT";
  zone_name: string;
};

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="py-20 text-center text-muted">Loading sign in portal…</div>}>
      <LoginContent />
    </Suspense>
  );
}

async function LoginContent() {
  const user = await getCurrentUser();

  // Fetch active gates for gate operator station choice
  const gates = await query<GateItem>(
    `SELECT g.gate_id, g.gate_number, g.gate_type, z.zone_name
       FROM parking_gate g
       JOIN parking_zone z ON z.zone_id = g.zone_id
      WHERE g.status = 'ACTIVE'
      ORDER BY g.gate_type, g.gate_number`
  );

  return (
    <div className="mx-auto max-w-3xl py-6 sm:py-10">
      {/* Header */}
      <div className="mb-8 text-center">
        <Link
          href="/"
          className="inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-accent text-accent-fg font-bold text-xl mb-4 shadow-sm hover:scale-105 transition"
        >
          P
        </Link>
        <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-foreground">
          SmartPark Staff & Terminal Access
        </h1>
        <p className="mt-2 text-sm text-muted max-w-lg mx-auto">
          Fast, frictionless authentication for viva evaluation. Click any role below for instant 1-click access or enter custom credentials.
        </p>

        {/* Current Active Session Banner (if already logged in) */}
        {user && (
          <div className="mt-5 mx-auto max-w-md rounded-xl border border-emerald-500/30 bg-emerald-500/10 p-3.5 flex items-center justify-between text-xs">
            <div className="text-left">
              <span className="text-muted">Active Session:</span>{" "}
              <strong className="text-foreground">{user.display_name}</strong>{" "}
              <span className="text-emerald-600 dark:text-emerald-400 font-semibold">({user.role})</span>
            </div>
            <div className="flex items-center gap-2">
              <Link
                href="/dashboard"
                className="font-semibold text-accent hover:underline"
              >
                Go to Dashboard →
              </Link>
              <form action={logoutAction}>
                <button
                  type="submit"
                  className="text-muted hover:text-rose-500 cursor-pointer ml-1"
                  title="Sign out"
                >
                  <Icon name="exit" className="h-3.5 w-3.5" />
                </button>
              </form>
            </div>
          </div>
        )}
      </div>

      <LoginForm gates={gates} />

      {/* Database Roles Reference Table */}
      <div className="mt-10 rounded-2xl border border-border bg-surface p-5">
        <h3 className="text-xs font-semibold uppercase tracking-wider text-muted mb-3 flex items-center gap-1.5">
          <Icon name="users" className="h-4 w-4" />
          Pre-seeded Database Roles & Test Credentials
        </h3>
        <div className="overflow-x-auto text-xs">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-border text-muted">
                <th className="py-2 font-medium">Role / Designation</th>
                <th className="py-2 font-medium">Login ID</th>
                <th className="py-2 font-medium">Password</th>
                <th className="py-2 font-medium">Default Gate Mode</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border/50 text-foreground/90 font-mono">
              <tr>
                <td className="py-2 font-sans font-medium text-emerald-600 dark:text-emerald-400">Gate Operator (Entry)</td>
                <td className="py-2 font-bold">gate_worker</td>
                <td className="py-2">gate123</td>
                <td className="py-2 font-sans text-emerald-600 dark:text-emerald-400 font-semibold">ENTRY (Fills slots)</td>
              </tr>
              <tr>
                <td className="py-2 font-sans font-medium text-rose-600 dark:text-rose-400">Gate Operator (Exit)</td>
                <td className="py-2 font-bold">gate_worker</td>
                <td className="py-2">gate123</td>
                <td className="py-2 font-sans text-rose-600 dark:text-rose-400 font-semibold">EXIT (Frees slots)</td>
              </tr>
              <tr>
                <td className="py-2 font-sans font-medium text-accent">System Admin</td>
                <td className="py-2 font-bold">admin</td>
                <td className="py-2">admin123</td>
                <td className="py-2 font-sans text-muted">Full Control</td>
              </tr>
              <tr>
                <td className="py-2 font-sans font-medium text-blue-600 dark:text-blue-400">Supervisor</td>
                <td className="py-2 font-bold">supervisor</td>
                <td className="py-2">super123</td>
                <td className="py-2 font-sans text-muted">Operations & Shifts</td>
              </tr>
              <tr>
                <td className="py-2 font-sans font-medium text-amber-600 dark:text-amber-400">Cashier</td>
                <td className="py-2 font-bold">cashier</td>
                <td className="py-2">cash123</td>
                <td className="py-2 font-sans text-muted">Payments & Exit Desk</td>
              </tr>
              <tr>
                <td className="py-2 font-sans font-medium text-purple-600 dark:text-purple-400">Security Guard</td>
                <td className="py-2 font-bold">security</td>
                <td className="py-2">sec123</td>
                <td className="py-2 font-sans text-muted">Surveillance / ANPR</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

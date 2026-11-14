import { Suspense } from "react";
import type { Metadata } from "next";
import { getCurrentUser } from "@/lib/auth";
import { query } from "@/lib/db";
import { redirect } from "next/navigation";
import { LoginForm } from "./LoginForm";
import Link from "next/link";
import { Icon } from "@/components/Icon";

export const metadata: Metadata = {
  title: "Sign In - Parking Management",
};

export type GateItem = {
  gate_id: number;
  gate_number: string;
  gate_type: "ENTRY" | "EXIT";
  zone_name: string;
};

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="py-20 text-center text-muted">Loading sign in…</div>}>
      <LoginContent />
    </Suspense>
  );
}

async function LoginContent() {
  const user = await getCurrentUser();

  if (user) {
    redirect("/");
  }

  // Fetch active gates for gate operator station choice
  const gates = await query<GateItem>(
    `SELECT g.gate_id, g.gate_number, g.gate_type, z.zone_name
       FROM parking_gate g
       JOIN parking_zone z ON z.zone_id = g.zone_id
      WHERE g.status = 'ACTIVE'
      ORDER BY g.gate_type, g.gate_number`
  );

  return (
    <div className="mx-auto max-w-2xl py-6 sm:py-10">
      {/* Header */}
      <div className="mb-8 text-center">
        <div className="inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-accent text-accent-fg font-bold text-xl mb-4 shadow-sm">
          P
        </div>
        <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-foreground">
          Sign In to Parking Management
        </h1>
        <p className="mt-2 text-sm text-muted">
          Select a role or enter your credentials. Gate workers can select their Entry or Exit station.
        </p>
      </div>

      <LoginForm gates={gates} />

      {/* Database Roles Reference Table */}
      <div className="mt-10 rounded-2xl border border-border bg-surface p-5">
        <h3 className="text-xs font-semibold uppercase tracking-wider text-muted mb-3 flex items-center gap-1.5">
          <Icon name="users" className="h-4 w-4" />
          All Database Roles & Login IDs
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
                <td className="py-2 font-sans text-rose-600 dark:text-rose-400 font-semibold">EXIT (Empties slots)</td>
              </tr>
              <tr>
                <td className="py-2 font-sans font-medium text-blue-600 dark:text-blue-400">Supervisor</td>
                <td className="py-2 font-bold">supervisor</td>
                <td className="py-2">super123</td>
                <td className="py-2 font-sans text-muted">Operations & Shifts</td>
              </tr>
              <tr>
                <td className="py-2 font-sans font-medium text-purple-600 dark:text-purple-400">Security Guard</td>
                <td className="py-2 font-bold">security</td>
                <td className="py-2">sec123</td>
                <td className="py-2 font-sans text-muted">Surveillance / ANPR</td>
              </tr>
              <tr>
                <td className="py-2 font-sans font-medium text-amber-600 dark:text-amber-400">Cashier</td>
                <td className="py-2 font-bold">cashier</td>
                <td className="py-2">cash123</td>
                <td className="py-2 font-sans text-muted">Payments & Exit Desk</td>
              </tr>
              <tr>
                <td className="py-2 font-sans font-medium text-rose-600 dark:text-rose-400">System Admin</td>
                <td className="py-2 font-bold">admin</td>
                <td className="py-2">admin123</td>
                <td className="py-2 font-sans text-muted">Full Control</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div className="mt-6 text-center">
        <Link
          href="/"
          className="text-xs text-muted hover:text-foreground inline-flex items-center gap-1.5"
        >
          <Icon name="home" className="h-3.5 w-3.5" />
          Continue to Dashboard without signing in
        </Link>
      </div>
    </div>
  );
}

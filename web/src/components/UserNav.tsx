"use client";

import { useEffect, useState, useTransition } from "react";
import Link from "next/link";
import { logoutAction, switchRoleAction } from "@/app/login/actions";
import { Icon } from "./Icon";
import type { AuthUser } from "@/lib/auth";

const ROLES = [
  { key: "admin", label: "System Admin", badge: "Full Access", color: "text-accent" },
  { key: "gate_entry", label: "Gate Entry (G-101)", badge: "Fills Slots", color: "text-emerald-500" },
  { key: "gate_exit", label: "Gate Exit (G-201)", badge: "Frees Slots", color: "text-rose-500" },
  { key: "supervisor", label: "Supervisor", badge: "Facility", color: "text-blue-500" },
  { key: "cashier", label: "Cashier", badge: "Billing Desk", color: "text-amber-500" },
  { key: "security", label: "Security Guard", badge: "Surveillance", color: "text-purple-500" },
  { key: "guest", label: "Guest Evaluator", badge: "Read Only", color: "text-muted" },
];

export function UserNav({ onNavigate }: { onNavigate?: () => void }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [menuOpen, setMenuOpen] = useState(false);
  const [isPending, startTransition] = useTransition();

  const fetchUser = () => {
    fetch("/api/auth/me")
      .then((res) => res.json())
      .then((data) => {
        setUser(data.user);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  };

  useEffect(() => {
    fetchUser();
  }, []);

  const handleRoleSwitch = (roleKey: string) => {
    setMenuOpen(false);
    startTransition(async () => {
      await switchRoleAction(roleKey);
      fetchUser();
      if (onNavigate) onNavigate();
    });
  };

  if (loading) {
    return (
      <div className="h-14 animate-pulse rounded-xl bg-surface-2/50 px-3 py-2" />
    );
  }

  if (!user) {
    return (
      <div className="space-y-2">
        <Link
          href="/login"
          onClick={onNavigate}
          className="flex items-center justify-between rounded-xl border border-dashed border-border bg-surface-2/40 px-3.5 py-2.5 text-xs text-foreground/80 transition hover:border-accent hover:bg-surface-2 hover:text-foreground"
        >
          <div className="flex items-center gap-2.5">
            <span className="grid h-7 w-7 place-items-center rounded-lg bg-accent-soft text-accent">
              <Icon name="users" className="h-4 w-4" />
            </span>
            <div>
              <div className="font-semibold text-foreground">1-Click Sign In</div>
              <div className="text-[11px] text-muted">College demo & staff</div>
            </div>
          </div>
          <Icon name="enter" className="h-4 w-4 text-muted" />
        </Link>
      </div>
    );
  }

  const initials = (user.display_name || "User")
    .split(" ")
    .map((n) => n[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();

  return (
    <div className="relative">
      {/* Active User Card with Role Switcher Trigger */}
      <div className="flex items-center justify-between rounded-xl border border-border bg-surface-2/60 px-3 py-2">
        <button
          type="button"
          onClick={() => setMenuOpen(!menuOpen)}
          className="flex items-center gap-2.5 min-w-0 text-left hover:opacity-85 transition cursor-pointer"
          title="Click to switch role"
        >
          <span className="grid h-8 w-8 shrink-0 place-items-center rounded-full bg-accent font-semibold text-xs text-accent-fg">
            {initials}
          </span>
          <div className="min-w-0">
            <div className="truncate text-xs font-semibold text-foreground leading-tight flex items-center gap-1">
              <span>{user.display_name}</span>
              <span className="text-[10px] text-muted">▾</span>
            </div>
            <div className="truncate text-[11px] text-muted leading-tight">
              {user.role}
              {user.gate_mode && (
                <span
                  className={`ml-1 font-semibold ${
                    user.gate_mode === "ENTRY" ? "text-emerald-500" : "text-rose-500"
                  }`}
                >
                  • {user.gate_mode}
                </span>
              )}
            </div>
          </div>
        </button>

        <div className="flex items-center gap-1">
          <button
            type="button"
            onClick={() => setMenuOpen(!menuOpen)}
            title="Quick switch role for viva demo"
            className="grid h-7 w-7 place-items-center rounded-lg text-muted transition hover:bg-surface hover:text-accent cursor-pointer"
          >
            <Icon name="users" className="h-4 w-4" />
          </button>

          <form action={logoutAction}>
            <button
              type="submit"
              title="Sign Out"
              className="grid h-7 w-7 place-items-center rounded-lg text-muted transition hover:bg-surface hover:text-rose-500 cursor-pointer"
            >
              <Icon name="exit" className="h-4 w-4" />
            </button>
          </form>
        </div>
      </div>

      {/* Quick Role Switcher Dropdown */}
      {menuOpen && (
        <>
          <div
            className="fixed inset-0 z-30"
            onClick={() => setMenuOpen(false)}
            aria-hidden
          />
          <div className="absolute bottom-full left-0 right-0 z-40 mb-2 rounded-xl border border-border bg-surface p-2 shadow-xl">
            <div className="px-2 py-1.5 text-[10px] font-semibold uppercase tracking-wider text-muted border-b border-border/60 mb-1 flex items-center justify-between">
              <span>Quick Role Switch (Viva Demo)</span>
              {isPending && (
                <span className="h-2.5 w-2.5 animate-spin rounded-full border border-accent border-t-transparent" />
              )}
            </div>
            <div className="space-y-0.5">
              {ROLES.map((r) => {
                const isActive =
                  user.role === r.label ||
                  (r.key === "admin" && user.role === "Admin") ||
                  (r.key === "gate_entry" && user.gate_mode === "ENTRY") ||
                  (r.key === "gate_exit" && user.gate_mode === "EXIT");

                return (
                  <button
                    key={r.key}
                    type="button"
                    onClick={() => handleRoleSwitch(r.key)}
                    disabled={isPending}
                    className={`flex w-full items-center justify-between rounded-lg px-2.5 py-1.5 text-xs transition cursor-pointer text-left ${
                      isActive
                        ? "bg-accent-soft font-semibold text-accent"
                        : "text-foreground hover:bg-surface-2"
                    }`}
                  >
                    <span className="flex items-center gap-2">
                      <span className={`h-1.5 w-1.5 rounded-full ${r.color.replace("text-", "bg-")}`} />
                      <span>{r.label}</span>
                    </span>
                    <span className="text-[10px] text-muted font-medium">{r.badge}</span>
                  </button>
                );
              })}
            </div>
            <div className="mt-1.5 pt-1.5 border-t border-border/60">
              <Link
                href="/login"
                onClick={() => {
                  setMenuOpen(false);
                  if (onNavigate) onNavigate();
                }}
                className="block text-center text-[11px] text-accent hover:underline py-0.5"
              >
                Open Full Sign-In Portal →
              </Link>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

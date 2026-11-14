"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { logoutAction } from "@/app/login/actions";
import { Icon } from "./Icon";
import type { AuthUser } from "@/lib/auth";

export function UserNav({ onNavigate }: { onNavigate?: () => void }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("/api/auth/me")
      .then((res) => res.json())
      .then((data) => {
        setUser(data.user);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="h-14 animate-pulse rounded-xl bg-surface-2/50 px-3 py-2" />
    );
  }

  if (!user) {
    return (
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
            <div className="font-semibold text-foreground">Sign In</div>
            <div className="text-[11px] text-muted">Gate & staff access</div>
          </div>
        </div>
        <Icon name="enter" className="h-4 w-4 text-muted" />
      </Link>
    );
  }

  const initials = user.display_name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();

  return (
    <div className="flex items-center justify-between rounded-xl border border-border bg-surface-2/60 px-3 py-2">
      <div className="flex items-center gap-2.5 min-w-0">
        <span className="grid h-8 w-8 shrink-0 place-items-center rounded-full bg-accent font-semibold text-xs text-accent-fg">
          {initials}
        </span>
        <div className="min-w-0">
          <div className="truncate text-xs font-semibold text-foreground leading-tight">
            {user.display_name}
          </div>
          <div className="truncate text-[11px] text-muted leading-tight">
            {user.role}
            {user.gate_mode && (
              <span className={`ml-1 font-semibold ${user.gate_mode === "ENTRY" ? "text-emerald-500" : "text-rose-500"}`}>
                • {user.gate_mode}
              </span>
            )}
          </div>
        </div>
      </div>

      <form action={logoutAction}>
        <button
          type="submit"
          title="Sign Out"
          className="grid h-7 w-7 place-items-center rounded-lg text-muted transition hover:bg-surface hover:text-foreground cursor-pointer"
        >
          <Icon name="exit" className="h-4 w-4" />
        </button>
      </form>
    </div>
  );
}

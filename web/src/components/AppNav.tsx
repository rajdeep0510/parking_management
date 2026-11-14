"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { Icon, type IconName } from "./Icon";
import { UserNav } from "./UserNav";

type NavLink = readonly [href: string, label: string, icon: IconName];

const NAV: readonly { heading: string; links: readonly NavLink[] }[] = [
  {
    heading: "Operations",
    links: [
      ["/", "Dashboard", "home"],
      ["/anpr", "ANPR Scanner", "camera"],
      ["/entry", "Vehicle Entry", "enter"],
      ["/tickets", "Active Tickets", "ticket"],
      ["/history", "History", "history"],
      ["/slots", "Slot Board", "grid"],
    ],
  },
  {
    heading: "Facility",
    links: [
      ["/zones", "Zones", "layers"],
      ["/slots/manage", "Slots", "square"],
      ["/slot-types", "Slot Types", "shapes"],
      ["/gates", "Gates", "gate"],
      ["/tariffs", "Tariffs", "rupee"],
    ],
  },
  {
    heading: "Vehicles",
    links: [
      ["/vehicles", "Vehicles", "car"],
      ["/vehicle-types", "Vehicle Types", "tag"],
    ],
  },
  {
    heading: "Membership",
    links: [
      ["/members", "Members", "users"],
      ["/plans", "Plans", "badge"],
      ["/passes", "Passes", "card"],
    ],
  },
  {
    heading: "Staff",
    links: [
      ["/staff", "Staff", "clipboard"],
      ["/shifts", "Shifts", "clock"],
    ],
  },
];

const TABS: readonly NavLink[] = [
  ["/", "Home", "home"],
  ["/anpr", "Scan", "camera"],
  ["/entry", "Entry", "enter"],
  ["/tickets", "Tickets", "ticket"],
  ["/slots", "Slots", "grid"],
];

const ALL_HREFS = NAV.flatMap((s) => s.links.map(([href]) => href));

/** The nav href that best matches the current path (longest prefix wins). */
function activeHref(pathname: string | null): string | null {
  if (!pathname) return null;
  if (pathname.startsWith("/exit/")) return "/tickets";
  let best: string | null = null;
  for (const href of ALL_HREFS) {
    const hit = href === "/" ? pathname === "/" : pathname === href || pathname.startsWith(`${href}/`);
    if (hit && (!best || href.length > best.length)) best = href;
  }
  return best;
}

export function AppNav() {
  return <NavFrame pathname={usePathname()} />;
}

/** Rendered without a pathname as the Suspense fallback on routes whose path isn't known at prerender time. */
export function NavFrame({ pathname }: { pathname: string | null }) {
  const [open, setOpen] = useState(false);
  const active = activeHref(pathname);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && setOpen(false);
    document.addEventListener("keydown", onKey);
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = "";
    };
  }, [open]);

  return (
    <>
      {/* Desktop sidebar */}
      <aside className="no-print sticky top-0 hidden h-screen w-64 shrink-0 flex-col border-r border-border bg-surface lg:flex">
        <Brand />
        <div className="flex-1 overflow-y-auto px-3 pb-4">
          <NavSections active={active} />
        </div>
        <div className="border-t border-border p-3 space-y-2">
          <div className="flex items-center gap-2 rounded-lg bg-surface-2 px-2.5 py-1.5 text-[11px] text-muted">
            <span className="relative flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-emerald-400 opacity-75" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-emerald-500" />
            </span>
            <span className="truncate font-medium text-foreground/80">System Live • 320 Slots</span>
          </div>
          <UserNav />
        </div>
      </aside>

      {/* Mobile top bar */}
      <header className="no-print sticky top-0 z-30 flex items-center justify-between border-b border-border/80 bg-surface/85 px-4 pt-[env(safe-area-inset-top)] backdrop-blur-xl lg:hidden">
        <Link href="/" className="flex h-14 items-center gap-2.5 font-semibold">
          <Logo />
          <span className="font-bold tracking-tight">Parking Hub</span>
        </Link>
        <button
          type="button"
          onClick={() => setOpen(true)}
          className="-mr-2 grid h-11 w-11 place-items-center rounded-xl hover:bg-surface-2 active:scale-95 transition-transform"
          aria-label="Open menu"
          aria-expanded={open}
        >
          <Icon name="menu" className="h-6 w-6" />
        </button>
      </header>

      {/* Mobile drawer backdrop */}
      <div
        className={`no-print fixed inset-0 z-40 bg-black/50 backdrop-blur-xs transition-opacity duration-300 lg:hidden ${
          open ? "opacity-100" : "pointer-events-none opacity-0"
        }`}
        onClick={() => setOpen(false)}
        aria-hidden
      />
      {/* Mobile drawer panel */}
      <nav
        className={`no-print fixed inset-y-0 right-0 z-50 flex w-[82%] max-w-xs flex-col bg-surface/95 backdrop-blur-2xl border-l border-border/60 pt-[env(safe-area-inset-top)] pb-[env(safe-area-inset-bottom)] shadow-2xl transition-transform duration-300 lg:hidden ${
          open ? "translate-x-0" : "translate-x-full"
        }`}
        aria-label="Main menu"
        inert={!open}
      >
        <div className="flex items-center justify-between pr-2">
          <Brand />
          <button
            type="button"
            onClick={() => setOpen(false)}
            className="grid h-11 w-11 place-items-center rounded-xl hover:bg-surface-2 active:scale-95 transition-transform"
            aria-label="Close menu"
          >
            <Icon name="close" className="h-6 w-6" />
          </button>
        </div>
        <div className="flex-1 overflow-y-auto px-3 pb-4">
          <NavSections active={active} onNavigate={() => setOpen(false)} />
        </div>
        <div className="border-t border-border p-3">
          <UserNav onNavigate={() => setOpen(false)} />
        </div>
      </nav>

      {/* Mobile bottom tab bar - Floating glass island dock */}
      <nav
        className="no-print fixed bottom-[calc(0.75rem+env(safe-area-inset-bottom))] inset-x-3 z-30 mx-auto max-w-md rounded-2xl border border-white/20 bg-surface/90 p-1.5 shadow-2xl backdrop-blur-xl ring-1 ring-black/5 dark:border-white/10 dark:ring-white/10 lg:hidden"
        aria-label="Quick navigation"
      >
        <ul className="grid grid-cols-5 gap-1">
          {TABS.map(([href, label, icon]) => {
            const isActive = active === href;
            return (
              <li key={href}>
                <Link
                  href={href}
                  className={`group flex flex-col items-center justify-center rounded-xl py-2 px-1 text-[11px] font-medium transition-all duration-150 active:scale-90 ${
                    isActive
                      ? "bg-accent text-accent-fg font-semibold shadow-md shadow-accent/25"
                      : "text-muted hover:bg-surface-2 hover:text-foreground"
                  }`}
                  aria-current={isActive ? "page" : undefined}
                >
                  <Icon
                    name={icon}
                    className={`h-5 w-5 transition-transform duration-150 ${
                      isActive ? "scale-105" : "group-hover:scale-105"
                    }`}
                  />
                  <span className="mt-0.5 tracking-tight text-[10px] leading-tight">{label}</span>
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>
    </>
  );
}

function Logo() {
  return (
    <span className="grid h-8 w-8 place-items-center rounded-lg bg-gradient-to-br from-indigo-500 to-accent text-sm font-bold text-accent-fg shadow-xs shadow-accent/30 transition-transform duration-200 group-hover:scale-105">
      P
    </span>
  );
}

function Brand() {
  return (
    <Link href="/" className="group flex h-16 items-center gap-2.5 px-5 font-semibold transition-opacity hover:opacity-90">
      <Logo />
      <span className="leading-tight transition-transform duration-150 group-hover:translate-x-0.5">
        Parking
        <span className="block text-xs font-normal text-muted">Management</span>
      </span>
    </Link>
  );
}

function NavSections({ active, onNavigate }: { active: string | null; onNavigate?: () => void }) {
  return (
    <div className="space-y-5">
      {NAV.map((section) => (
        <div key={section.heading}>
          <div className="mb-1 px-3 text-[11px] font-semibold uppercase tracking-wider text-muted">
            {section.heading}
          </div>
          <ul className="space-y-0.5">
            {section.links.map(([href, label, icon]) => {
              const isActive = active === href;
              return (
                <li key={href} className="relative">
                  {isActive && (
                    <span
                      className="absolute -left-3 top-1.5 bottom-1.5 w-1 rounded-r-full bg-accent shadow-xs shadow-accent/50"
                      aria-hidden="true"
                    />
                  )}
                  <Link
                    href={href}
                    onClick={onNavigate}
                    aria-current={isActive ? "page" : undefined}
                    className={`flex min-h-10 items-center gap-3 rounded-lg px-3 text-sm transition-all duration-150 ease-out active:scale-[0.98] ${
                      isActive
                        ? "bg-accent-soft font-semibold text-accent shadow-xs"
                        : "text-foreground/80 hover:bg-surface-2 hover:text-foreground hover:translate-x-0.5"
                    }`}
                  >
                    <Icon name={icon} className={`h-[18px] w-[18px] shrink-0 transition-transform duration-150 ${isActive ? "scale-105" : ""}`} />
                    {label}
                  </Link>
                </li>
              );
            })}
          </ul>
        </div>
      ))}
    </div>
  );
}

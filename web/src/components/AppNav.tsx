"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { Icon, type IconName } from "./Icon";
import { UserNav } from "./UserNav";

type NavLink = readonly [href: string, label: string, icon: IconName];

const NAV: readonly { heading: string; links: readonly NavLink[] }[] = [
  {
    heading: "Overview",
    links: [
      ["/", "Project Landing", "badge"],
      ["/dashboard", "Dashboard", "home"],
    ],
  },
  {
    heading: "Operations",
    links: [
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
  ["/dashboard", "Home", "home"],
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
  const pathname = usePathname();
  if (pathname === "/") return null;
  return <NavFrame pathname={pathname} />;
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
      <aside className="sticky top-0 hidden h-screen w-64 shrink-0 flex-col border-r border-border bg-surface lg:flex">
        <Brand />
        <div className="flex-1 overflow-y-auto px-3 pb-4">
          <NavSections active={active} />
        </div>
        <div className="border-t border-border p-3">
          <UserNav />
        </div>
      </aside>

      {/* Mobile top bar */}
      <header className="sticky top-0 z-30 flex items-center justify-between border-b border-border bg-surface/85 px-4 pt-[env(safe-area-inset-top)] backdrop-blur-md lg:hidden">
        <Link href="/" className="flex h-14 items-center gap-2.5 font-semibold">
          <Logo />
          Parking
        </Link>
        <button
          type="button"
          onClick={() => setOpen(true)}
          className="-mr-2 grid h-11 w-11 place-items-center rounded-lg hover:bg-surface-2"
          aria-label="Open menu"
          aria-expanded={open}
        >
          <Icon name="menu" className="h-6 w-6" />
        </button>
      </header>

      {/* Mobile drawer */}
      <div
        className={`fixed inset-0 z-40 bg-black/40 backdrop-blur-sm transition-opacity lg:hidden ${
          open ? "opacity-100" : "pointer-events-none opacity-0"
        }`}
        onClick={() => setOpen(false)}
        aria-hidden
      />
      <nav
        className={`fixed inset-y-0 right-0 z-50 flex w-[82%] max-w-xs flex-col bg-surface pt-[env(safe-area-inset-top)] pb-[env(safe-area-inset-bottom)] shadow-2xl transition-transform duration-300 lg:hidden ${
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
            className="grid h-11 w-11 place-items-center rounded-lg hover:bg-surface-2"
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

      {/* Mobile bottom tab bar */}
      <nav
        className="fixed inset-x-0 bottom-0 z-30 border-t border-border bg-surface/90 pb-[env(safe-area-inset-bottom)] backdrop-blur-md lg:hidden"
        aria-label="Quick navigation"
      >
        <ul className="mx-auto grid max-w-lg grid-cols-5">
          {TABS.map(([href, label, icon]) => {
            const isActive = active === href;
            return (
              <li key={href}>
                <Link
                  href={href}
                  className={`flex h-16 flex-col items-center justify-center gap-1 text-[11px] font-medium transition-colors ${
                    isActive ? "text-accent" : "text-muted hover:text-foreground"
                  }`}
                  aria-current={isActive ? "page" : undefined}
                >
                  <span className={`grid h-7 w-12 place-items-center rounded-full ${isActive ? "bg-accent-soft" : ""}`}>
                    <Icon name={icon} className="h-5 w-5" />
                  </span>
                  {label}
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
    <span className="grid h-8 w-8 place-items-center rounded-lg bg-accent text-sm font-bold text-accent-fg">P</span>
  );
}

function Brand() {
  return (
    <Link href="/" className="flex h-16 items-center gap-2.5 px-5 font-semibold">
      <Logo />
      <span className="leading-tight">
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
                <li key={href}>
                  <Link
                    href={href}
                    onClick={onNavigate}
                    aria-current={isActive ? "page" : undefined}
                    className={`flex min-h-10 items-center gap-3 rounded-lg px-3 text-sm transition-colors ${
                      isActive
                        ? "bg-accent-soft font-semibold text-accent"
                        : "text-foreground/80 hover:bg-surface-2 hover:text-foreground"
                    }`}
                  >
                    <Icon name={icon} className="h-[18px] w-[18px] shrink-0" />
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

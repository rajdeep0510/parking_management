"use client";

import { usePathname } from "next/navigation";
import { Suspense, type ReactNode } from "react";
import { AppNav, NavFrame } from "./AppNav";

function ShellContent({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const isLandingPage = pathname === "/";

  if (isLandingPage) {
    return (
      <main className="min-h-screen w-full bg-background text-foreground">
        {children}
      </main>
    );
  }

  return (
    <div className="min-h-screen w-full lg:flex bg-background text-foreground">
      <Suspense fallback={<NavFrame pathname={null} />}>
        <AppNav />
      </Suspense>
      <main className="mx-auto w-full max-w-6xl min-w-0 flex-1 px-4 pt-5 pb-[calc(6rem+env(safe-area-inset-bottom))] sm:px-6 lg:px-10 lg:pt-8 lg:pb-10">
        {children}
      </main>
    </div>
  );
}

export function AppShell({ children }: { children: ReactNode }) {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen w-full lg:flex bg-background text-foreground">
          <NavFrame pathname={null} />
          <main className="mx-auto w-full max-w-6xl min-w-0 flex-1 px-4 pt-5 pb-[calc(6rem+env(safe-area-inset-bottom))] sm:px-6 lg:px-10 lg:pt-8 lg:pb-10">
            {children}
          </main>
        </div>
      }
    >
      <ShellContent>{children}</ShellContent>
    </Suspense>
  );
}

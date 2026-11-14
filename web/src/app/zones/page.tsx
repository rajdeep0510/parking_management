import { Suspense } from "react";
import { CrudPage } from "@/components/CrudPage";

export default function Page({ searchParams }: PageProps<"/zones">) {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <CrudPage tableKey="parking_zone" searchParams={searchParams} />
    </Suspense>
  );
}

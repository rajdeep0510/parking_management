import { Suspense } from "react";
import { CrudPage } from "@/components/CrudPage";

export default function Page({ searchParams }: PageProps<"/vehicle-types">) {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <CrudPage tableKey="vehicle_type" searchParams={searchParams} />
    </Suspense>
  );
}

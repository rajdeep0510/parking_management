import { Suspense } from "react";
import { CrudPage } from "@/components/CrudPage";

export default function Page({ searchParams }: PageProps<"/slot-types">) {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <CrudPage tableKey="slot_type" searchParams={searchParams} />
    </Suspense>
  );
}

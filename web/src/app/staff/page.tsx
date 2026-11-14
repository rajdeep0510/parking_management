import { Suspense } from "react";
import { CrudPage } from "@/components/CrudPage";

export default function Page({ searchParams }: PageProps<"/staff">) {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <CrudPage tableKey="staff_details" searchParams={searchParams} />
    </Suspense>
  );
}

import { Suspense } from "react";
import { CrudPage } from "@/components/CrudPage";

export default function Page({ searchParams }: PageProps<"/tariffs">) {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <CrudPage tableKey="tariff" searchParams={searchParams} />
    </Suspense>
  );
}

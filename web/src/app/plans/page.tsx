import { Suspense } from "react";
import Link from "next/link";
import { query } from "@/lib/db";
import { getTable } from "@/lib/tables";
import { loadFormFields } from "@/components/CrudPage";
import { RowForm } from "@/components/RowForm";
import { DeleteButton } from "@/components/DeleteButton";
import { Icon } from "@/components/Icon";

type Plan = {
  plan_id: number;
  plan_name: string;
  duration_days: number;
  price: number;
  description: string | null;
  active_passes: number;
};

const TERMS = [
  ["all", "All plans"],
  ["monthly", "Monthly"],
  ["long", "Long-term"],
] as const;

const inr = new Intl.NumberFormat("en-IN", { style: "currency", currency: "INR", maximumFractionDigits: 0 });

function period(days: number) {
  return { 7: "week", 30: "month", 90: "quarter", 180: "6 months", 365: "year" }[days] ?? `${days} days`;
}

export default function PlansPage({ searchParams }: PageProps<"/plans">) {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <PlansContent searchParams={searchParams} />
    </Suspense>
  );
}

async function PlansContent({ searchParams }: { searchParams: PageProps<"/plans">["searchParams"] }) {
  const cfg = getTable("membership_plan");
  const params = await searchParams;
  const edit = typeof params.edit === "string" ? params.edit : undefined;
  const term = TERMS.some(([k]) => k === params.term) ? (params.term as string) : "all";

  const [plans, fields] = await Promise.all([
    query<Plan>(
      `SELECT p.*, count(mp.pass_no) FILTER (
                WHERE mp.status = 'ACTIVE' AND CURRENT_DATE BETWEEN mp.start_date AND mp.end_date) AS active_passes
         FROM membership_plan p
         LEFT JOIN membership_pass mp ON mp.plan_id = p.plan_id
        GROUP BY p.plan_id
        ORDER BY p.duration_days, p.price`,
    ),
    loadFormFields(cfg),
  ]);
  const editing = edit ? (plans.find((p) => String(p.plan_id) === edit) ?? null) : null;

  const shown = plans.filter((p) => (term === "monthly" ? p.duration_days <= 31 : term === "long" ? p.duration_days > 31 : true));
  const topPasses = Math.max(0, ...plans.map((p) => p.active_passes));

  const form = (
    <RowForm
      tableKey="membership_plan"
      fields={fields}
      initial={editing}
      pkValue={editing ? String(editing.plan_id) : null}
      cancelHref={cfg.path}
    />
  );

  return (
    <div className="space-y-6">
      <div className="text-center">
        <h1 className="page-title">Membership Plans</h1>
        <p className="mx-auto mt-1 max-w-xl text-sm text-muted sm:text-base">
          Prepaid passes for regular parkers. While a pass is active, the vehicle exits without hourly charges.
        </p>
      </div>

      <nav className="flex justify-center" aria-label="Filter plans">
        <div className="inline-flex rounded-xl border border-border bg-surface p-1">
          {TERMS.map(([key, label]) => (
            <Link
              key={key}
              href={key === "all" ? cfg.path : `${cfg.path}?term=${key}`}
              aria-current={term === key ? "page" : undefined}
              className={`rounded-lg px-3.5 py-2 text-sm font-medium transition sm:px-5 ${
                term === key ? "bg-foreground text-background shadow-sm" : "text-muted hover:text-foreground"
              }`}
            >
              {label}
            </Link>
          ))}
        </div>
      </nav>

      {editing && form}

      <div className="grid gap-5 pt-3 md:grid-cols-2 xl:grid-cols-3">
        {shown.map((p) => (
          <PlanCard key={p.plan_id} plan={p} popular={topPasses > 0 && p.active_passes === topPasses} />
        ))}
        {shown.length === 0 && <p className="text-center text-muted md:col-span-2 xl:col-span-3">No plans in this group yet.</p>}
      </div>

      {!editing && form}
    </div>
  );
}

function PlanCard({ plan: p, popular }: { plan: Plan; popular: boolean }) {
  const [summary, ...extra] = (p.description ?? "")
    .split("\n")
    .map((l) => l.trim())
    .filter(Boolean);
  const features = [
    ...extra,
    `Valid for ${p.duration_days} days from the start date`,
    `Works out to ${inr.format(p.price / p.duration_days)} per day`,
    "Unlimited entries and exits",
    "No hourly charges at exit while active",
    "Linked to one registered vehicle",
  ];

  return (
    <article
      className={`relative flex flex-col rounded-2xl border bg-surface p-6 shadow-(--shadow) ${
        popular ? "border-green-500/60 ring-1 ring-green-500/30" : "border-border"
      }`}
    >
      {popular && (
        <span className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-green-500 px-3 py-1 text-[11px] font-bold tracking-wide whitespace-nowrap text-white uppercase dark:text-black">
          Most popular
        </span>
      )}

      <h2 className="flex items-center gap-2 text-lg font-semibold">
        {p.plan_name}
        <Icon name="badge" className="h-5 w-5 shrink-0 text-accent" />
      </h2>

      <div className="mt-4 flex items-baseline gap-1.5">
        <span className={`text-4xl font-bold tracking-tight tabular-nums ${popular ? "text-green-600 dark:text-green-400" : ""}`}>
          {inr.format(p.price)}
        </span>
        <span className="text-sm text-muted">/ {period(p.duration_days)}</span>
      </div>

      {summary && <p className="mt-3 text-sm leading-relaxed text-muted">{summary}</p>}

      <hr className="my-5 border-border" />

      <ul className="flex-1 space-y-3 text-sm">
        {features.map((f) => (
          <li key={f} className="flex gap-2.5">
            <Icon name="check" className="mt-0.5 h-4 w-4 shrink-0 text-green-600 dark:text-green-400" />
            <span>{f}</span>
          </li>
        ))}
      </ul>

      <div className="mt-6 flex items-center gap-1.5 text-xs text-muted">
        <Icon name="users" className="h-4 w-4" />
        {p.active_passes} active {p.active_passes === 1 ? "pass" : "passes"}
      </div>

      <div className="mt-3 grid gap-2">
        <Link href="/passes" className={popular ? "btn-primary min-h-11" : "btn min-h-11"}>
          Issue pass
        </Link>
        <div className="flex items-start gap-2 [&>*]:flex-1 [&_.btn-danger]:w-full">
          <Link href={`/plans?edit=${p.plan_id}`} className="btn">
            <Icon name="pencil" className="h-4 w-4" />
            Edit
          </Link>
          <DeleteButton tableKey="membership_plan" id={String(p.plan_id)} />
        </div>
      </div>
    </article>
  );
}

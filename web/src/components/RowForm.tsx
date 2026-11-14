"use client";

import Link from "next/link";
import { useActionState } from "react";
import { saveRow, type FormState } from "@/app/crud-actions";
import type { FieldType } from "@/lib/tables";

export type FormField = {
  name: string;
  label: string;
  type: FieldType;
  required?: boolean;
  step?: string;
  hint?: string;
  choices?: { value: string; label: string }[];
};

export function RowForm({
  tableKey,
  fields,
  initial,
  pkValue,
  cancelHref,
}: {
  tableKey: string;
  fields: FormField[];
  initial?: Record<string, unknown> | null;
  pkValue?: string | null;
  cancelHref: string;
}) {
  const [state, action, pending] = useActionState<FormState, FormData>(saveRow.bind(null, tableKey), {
    error: null,
  });

  return (
    <form
      action={action}
      className={`card space-y-4 ${pkValue ? "ring-2 ring-accent/40" : ""}`}
      key={pkValue ?? "new"}
    >
      <h2 className="font-semibold">{pkValue ? `Edit #${pkValue}` : "Add new"}</h2>
      {pkValue && <input type="hidden" name="__pk" value={pkValue} />}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {fields.map((f) => (
          <Input key={f.name} field={f} value={initial?.[f.name]} />
        ))}
      </div>
      {state.error && <p className="error">{state.error}</p>}
      <div className="grid grid-cols-1 gap-2 sm:flex">
        <button className="btn-primary" disabled={pending}>
          {pending ? "Saving…" : pkValue ? "Update" : "Add"}
        </button>
        {pkValue && (
          <Link href={cancelHref} className="btn">
            Cancel
          </Link>
        )}
      </div>
    </form>
  );
}

function Input({ field: f, value }: { field: FormField; value: unknown }) {
  const v = value == null ? "" : String(value);
  const common = { name: f.name, required: f.required, defaultValue: v, className: "input" };
  return (
    <label className={f.type === "textarea" ? "block sm:col-span-2 lg:col-span-3" : "block"}>
      <span className="label">
        {f.label}
        {f.required && " *"}
      </span>
      {f.type === "select" ? (
        <select {...common}>
          <option value="">{f.required ? "Select…" : "— none —"}</option>
          {f.choices?.map((c) => (
            <option key={c.value} value={c.value}>
              {c.label}
            </option>
          ))}
        </select>
      ) : f.type === "textarea" ? (
        <textarea {...common} rows={4} />
      ) : (
        <input {...common} type={f.type} step={f.type === "time" ? "1" : f.step} />
      )}
      {f.hint && <span className="mt-1 block text-xs text-muted">{f.hint}</span>}
    </label>
  );
}

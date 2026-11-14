import Link from "next/link";
import { query } from "@/lib/db";
import { getTable, type TableConfig, type TableKey } from "@/lib/tables";
import { RowForm, type FormField } from "./RowForm";
import { DeleteButton } from "./DeleteButton";
import { StatusBadge, isStatus } from "./StatusBadge";
import { Icon } from "./Icon";

/** Resolves a table's form fields, running lookup queries for foreign-key dropdowns. */
export function loadFormFields(cfg: TableConfig): Promise<FormField[]> {
  return Promise.all(
    cfg.fields.map(async (f): Promise<FormField> => {
      const choices = f.lookup
        ? (await query<{ value: number; label: string }>(f.lookup)).map((r) => ({
            value: String(r.value),
            label: r.label,
          }))
        : f.options?.map((o) => ({ value: o, label: o }));
      return { name: f.name, label: f.label, type: f.type, required: f.required, step: f.step, hint: f.hint, choices };
    }),
  );
}

export async function CrudPage({
  tableKey,
  searchParams,
}: {
  tableKey: TableKey;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const cfg = getTable(tableKey);
  const editParam = (await searchParams).edit;
  const edit = typeof editParam === "string" ? editParam : undefined;

  const [rows, editing, fields] = await Promise.all([
    query(cfg.listSql),
    edit ? query(`SELECT * FROM ${cfg.table} WHERE ${cfg.pk} = $1`, [edit]).then((r) => r[0] ?? null) : null,
    loadFormFields(cfg),
  ]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="page-title">{cfg.title}</h1>
        <p className="page-subtitle">
          {rows.length} {rows.length === 1 ? "record" : "records"}
        </p>
      </div>
      <RowForm
        tableKey={tableKey}
        fields={fields}
        initial={editing}
        pkValue={editing ? String(editing[cfg.pk]) : null}
        cancelHref={cfg.path}
      />
      <div className="card overflow-hidden p-0 md:overflow-x-auto">
        <table className="table table-stack">
          <thead>
            <tr>
              {cfg.columns.map((c) => (
                <th key={c.key}>{c.label}</th>
              ))}
              <th />
            </tr>
          </thead>
          <tbody>
            {rows.length === 0 && (
              <tr>
                <td colSpan={cfg.columns.length + 1} className="cell-empty text-center text-muted">
                  No rows yet
                </td>
              </tr>
            )}
            {rows.map((r) => {
              const id = String(r[cfg.pk]);
              return (
                <tr key={id}>
                  {cfg.columns.map((c) => (
                    <td key={c.key} data-label={c.label}>
                      {isStatus(r[c.key]) ? <StatusBadge value={r[c.key]} /> : (r[c.key] ?? "—")}
                    </td>
                  ))}
                  <td className="cell-actions">
                    <div className="flex flex-wrap items-start justify-end gap-2">
                      <Link href={`${cfg.path}?edit=${id}`} className="btn">
                        <Icon name="pencil" className="h-4 w-4" />
                        Edit
                      </Link>
                      <DeleteButton tableKey={tableKey} id={id} />
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

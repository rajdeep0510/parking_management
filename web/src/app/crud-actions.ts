"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { dbErrorMessage, withTransaction } from "@/lib/db";
import { getTable } from "@/lib/tables";

export type FormState = { error: string | null };

export async function saveRow(tableKey: string, _prev: FormState, formData: FormData): Promise<FormState> {
  const cfg = getTable(tableKey);
  const pkValue = formData.get("__pk")?.toString() || null;

  // Only columns declared in the table config are ever written (column names never come from the client).
  const values: Record<string, unknown> = {};
  for (const f of cfg.fields) {
    const raw = formData.get(f.name)?.toString().trim() ?? "";
    values[f.name] = raw === "" ? null : raw;
  }

  try {
    await withTransaction(async (client) => {
      await cfg.beforeSave?.(values, client);
      const cols = Object.keys(values);
      const params = cols.map((c) => values[c]);
      if (pkValue) {
        const sets = cols.map((c, i) => `${c} = $${i + 1}`).join(", ");
        await client.query(`UPDATE ${cfg.table} SET ${sets} WHERE ${cfg.pk} = $${cols.length + 1}`, [
          ...params,
          pkValue,
        ]);
      } else {
        const placeholders = cols.map((_, i) => `$${i + 1}`).join(", ");
        await client.query(`INSERT INTO ${cfg.table} (${cols.join(", ")}) VALUES (${placeholders})`, params);
      }
    });
  } catch (err) {
    return { error: dbErrorMessage(err) };
  }

  revalidatePath(cfg.path);
  redirect(cfg.path);
}

export async function deleteRow(tableKey: string, id: string): Promise<FormState> {
  const cfg = getTable(tableKey);
  try {
    await withTransaction((client) => client.query(`DELETE FROM ${cfg.table} WHERE ${cfg.pk} = $1`, [id]));
  } catch (err) {
    return { error: dbErrorMessage(err) };
  }
  revalidatePath(cfg.path);
  return { error: null };
}

import "server-only";
import { Pool, PoolClient, QueryResultRow, types } from "pg";
import { connection } from "next/server";

// Keep DATE / TIMESTAMP as plain strings (no JS timezone shifting) and NUMERIC as numbers.
types.setTypeParser(1082, (v) => v); // date
types.setTypeParser(1114, (v) => v); // timestamp without time zone
types.setTypeParser(1700, (v) => Number(v)); // numeric
types.setTypeParser(20, (v) => Number(v)); // bigint (count(*))

const globalForPg = globalThis as unknown as { pgPool?: Pool };

const rawUrl = process.env.DATABASE_URL;

// Normalize connection string to silence pg/pg-connection-string libpq compatibility warning
const connectionString =
  rawUrl && rawUrl.includes("sslmode=require") && !rawUrl.includes("uselibpqcompat")
    ? rawUrl.replace("sslmode=require", "uselibpqcompat=true&sslmode=require")
    : rawUrl;

const isCloudDb =
  connectionString?.includes("neon.tech") ||
  connectionString?.includes("supabase") ||
  connectionString?.includes("pooler") ||
  connectionString?.includes("sslmode=");

export const pool =
  globalForPg.pgPool ??
  new Pool({
    connectionString,
    ssl: isCloudDb ? { rejectUnauthorized: false } : undefined,
  });

if (process.env.NODE_ENV !== "production") globalForPg.pgPool = pool;

export async function query<T extends QueryResultRow = QueryResultRow>(
  sql: string,
  params: unknown[] = [],
): Promise<T[]> {
  // DB reads must happen per request, never at build-time prerender.
  await connection();
  const res = await pool.query<T>(sql, params);
  return res.rows;
}

export async function withTransaction<T>(fn: (client: PoolClient) => Promise<T>): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const result = await fn(client);
    await client.query("COMMIT");
    return result;
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
}

/** Turns a pg error into a message suitable for showing in a form. */
export function dbErrorMessage(err: unknown): string {
  const e = err as { code?: string; detail?: string; message?: string; constraint?: string };
  switch (e.code) {
    case "23505":
      return `Duplicate value: ${e.detail ?? "a unique field already exists"}`;
    case "23503": // foreign_key_violation
    case "23001": // restrict_violation (ON DELETE RESTRICT)
      return `Cannot do that — this record is linked to other records. ${e.detail ?? e.message ?? ""}`;
    case "23514":
      return `Value not allowed (${e.constraint ?? "check constraint"}).`;
    case "23502":
      return `A required field is missing: ${e.message ?? ""}`;
    case "22P02":
    case "22007":
    case "22008":
      return `Invalid value format: ${e.message ?? ""}`;
    default:
      return e.message ?? "Unknown database error";
  }
}

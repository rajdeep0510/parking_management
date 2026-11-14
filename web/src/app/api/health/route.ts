import { query, dbErrorMessage } from "@/lib/db";

export async function GET() {
  try {
    const [row] = await query<{ now: string; db: string }>(
      "SELECT LOCALTIMESTAMP::text AS now, current_database() AS db",
    );
    return Response.json({ ok: true, ...row });
  } catch (err) {
    return Response.json({ ok: false, error: dbErrorMessage(err) }, { status: 500 });
  }
}

import "server-only";
import type { Pool, PoolClient } from "pg";

export type FareQuote = {
  ticket_no: number;
  ticket_status: string;
  vehicle_id: number;
  registration_no: string;
  type_name: string;
  slot_id: number;
  slot_no: string;
  entry_time: string;
  exit_time: string;
  day_type: string;
  total_hours: number;
  regular_hours: number;
  overtime_hours: number;
  hourly_rate: number;
  overtime_rate: number;
  tariff_id: number | null;
  pass_no: number | null;
  amount: number;
  error: string | null;
};

/**
 * Computes the parking fee for a ticket as of "now" (LOCALTIMESTAMP).
 * - Billable hours are rounded up, minimum 1.
 * - Hours inside the tariff's start/end window use hourly_rate; the rest use overtime_rate.
 * - An ACTIVE membership pass valid today makes the stay free.
 */
export async function getFareQuote(db: Pool | PoolClient, ticketNo: number): Promise<FareQuote | null> {
  const { rows } = await db.query(
    `SELECT t.ticket_no, t.ticket_status, t.entry_time::text AS entry_time,
            LOCALTIMESTAMP(0)::text AS exit_time,
            v.vehicle_id, v.registration_no, v.type_id, vt.type_name, s.slot_id, s.slot_no,
            GREATEST(1, CEIL(EXTRACT(EPOCH FROM (LOCALTIMESTAMP(0) - t.entry_time)) / 3600))::int AS total_hours,
            CASE WHEN EXTRACT(ISODOW FROM t.entry_time) IN (6, 7) THEN 'WEEKEND' ELSE 'WEEKDAY' END AS day_type
       FROM parking_ticket t
       JOIN vehicle v ON v.vehicle_id = t.vehicle_id
       JOIN vehicle_type vt ON vt.type_id = v.type_id
       JOIN parking_slot s ON s.slot_id = t.slot_id
      WHERE t.ticket_no = $1`,
    [ticketNo],
  );
  const t = rows[0];
  if (!t) return null;

  const tariffRes = await db.query(
    `SELECT tariff_id, hourly_rate, overtime_rate,
            ($2::timestamp::time BETWEEN start_time AND end_time) AS in_window,
            EXTRACT(EPOCH FROM (LEAST($3::timestamp, $2::timestamp::date + end_time) - $2::timestamp))::float AS regular_secs
       FROM tariff
      WHERE type_id = $1 AND day_type = $4
        AND $2::timestamp::date BETWEEN valid_from AND valid_to
      ORDER BY in_window DESC, valid_from DESC, tariff_id DESC
      LIMIT 1`,
    [t.type_id, t.entry_time, t.exit_time, t.day_type],
  );
  const tariff = tariffRes.rows[0];

  const passRes = await db.query(
    `SELECT pass_no FROM membership_pass
      WHERE vehicle_id = $1 AND status = 'ACTIVE'
        AND $2::timestamp::date BETWEEN start_date AND end_date
      LIMIT 1`,
    [t.vehicle_id, t.exit_time],
  );
  const passNo: number | null = passRes.rows[0]?.pass_no ?? null;

  const quote: FareQuote = {
    ticket_no: t.ticket_no,
    ticket_status: t.ticket_status,
    vehicle_id: t.vehicle_id,
    registration_no: t.registration_no,
    type_name: t.type_name,
    slot_id: t.slot_id,
    slot_no: t.slot_no,
    entry_time: t.entry_time,
    exit_time: t.exit_time,
    day_type: t.day_type,
    total_hours: t.total_hours,
    regular_hours: 0,
    overtime_hours: 0,
    hourly_rate: 0,
    overtime_rate: 0,
    tariff_id: null,
    pass_no: passNo,
    amount: 0,
    error: null,
  };

  if (passNo !== null) return quote;

  if (!tariff) {
    quote.error = `No ${t.day_type} tariff configured for vehicle type "${t.type_name}" on this date. Add one on the Tariffs page.`;
    return quote;
  }

  const regular = tariff.in_window
    ? Math.min(t.total_hours, Math.max(0, Math.ceil(tariff.regular_secs / 3600)))
    : 0;
  quote.tariff_id = tariff.tariff_id;
  quote.hourly_rate = tariff.hourly_rate;
  quote.overtime_rate = tariff.overtime_rate;
  quote.regular_hours = regular;
  quote.overtime_hours = t.total_hours - regular;
  quote.amount = regular * tariff.hourly_rate + quote.overtime_hours * tariff.overtime_rate;
  return quote;
}

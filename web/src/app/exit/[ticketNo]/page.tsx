import { Suspense } from "react";
import Link from "next/link";
import { notFound } from "next/navigation";
import { pool, query } from "@/lib/db";
import { getFareQuote } from "@/lib/fare";
import { StatusBadge } from "@/components/StatusBadge";
import { Icon } from "@/components/Icon";
import { ExitForm } from "./ExitForm";

export default function ExitPage({ params }: PageProps<"/exit/[ticketNo]">) {
  return (
    <Suspense fallback={<p className="text-muted">Loading…</p>}>
      <ExitContent params={params} />
    </Suspense>
  );
}

async function ExitContent({ params }: { params: PageProps<"/exit/[ticketNo]">["params"] }) {
  const ticketNo = Number((await params).ticketNo);
  if (!Number.isInteger(ticketNo)) notFound();

  // query() opts this page into per-request rendering; the gates list is needed anyway.
  const gates = await query<{ value: number; label: string }>(
    `SELECT gate_id AS value, gate_number || ' (' || gate_type || ')' AS label
       FROM parking_gate WHERE status = 'ACTIVE'
      ORDER BY (gate_type = 'EXIT') DESC, gate_number`,
  );
  const quote = await getFareQuote(pool, ticketNo);
  if (!quote) notFound();

  if (quote.ticket_status !== "ACTIVE") {
    const [receipt] = await query<{
      exit_time: string;
      gate_number: string;
      total_hours: number;
      total_amount: number;
      payment_id: number | null;
      payment_mode: string | null;
      payment_status: string | null;
      amount_paid: number | null;
    }>(
      `SELECT to_char(e.exit_time, 'YYYY-MM-DD HH24:MI') AS exit_time, g.gate_number, e.total_hours, e.total_amount,
              p.payment_id, p.payment_mode, p.payment_status, p.amount_paid
         FROM parking_exit e
         JOIN parking_gate g ON g.gate_id = e.exit_gate_id
         LEFT JOIN payment_details p ON p.exit_id = e.exit_id
        WHERE e.ticket_no = $1`,
      [ticketNo],
    );
    return (
      <div className="mx-auto max-w-xl space-y-5">
        <BackLink />
        <h1 className="page-title flex flex-wrap items-center gap-2">
          Ticket #{ticketNo} <StatusBadge value={quote.ticket_status} />
        </h1>
        <div className="card space-y-2.5 text-sm">
          <Row label="Vehicle" value={`${quote.registration_no} (${quote.type_name})`} />
          <Row label="Slot" value={quote.slot_no} />
          <Row label="Entry" value={quote.entry_time.slice(0, 16)} />
          {receipt ? (
            <>
              <Row label="Exit" value={`${receipt.exit_time} via ${receipt.gate_number}`} />
              <Row label="Hours billed" value={String(receipt.total_hours)} />
              <Row label="Amount" value={`₹${receipt.total_amount.toFixed(2)}`} />
              {receipt.payment_id && (
                <Row
                  label="Payment"
                  value={`#${receipt.payment_id} · ${receipt.payment_mode} · ${receipt.payment_status} · ₹${receipt.amount_paid?.toFixed(2)}`}
                />
              )}
            </>
          ) : (
            <p className="text-muted">No exit record (ticket was {quote.ticket_status.toLowerCase()}).</p>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-xl space-y-5">
      <BackLink />
      <div>
        <h1 className="page-title">Exit · Ticket #{ticketNo}</h1>
        <p className="mt-1 font-mono text-lg font-semibold tracking-wider">{quote.registration_no}</p>
      </div>
      <div className="card space-y-2.5 text-sm">
        <Row label="Vehicle type" value={quote.type_name} />
        <Row label="Slot" value={quote.slot_no} />
        <Row label="Entry" value={quote.entry_time.slice(0, 16)} />
        <Row label="Exit (now)" value={quote.exit_time.slice(0, 16)} />
        <Row label="Day type" value={quote.day_type} />
        <Row label="Billable hours" value={String(quote.total_hours)} />
        {quote.pass_no !== null ? (
          <p className="success">Membership pass #{quote.pass_no} is active — no charge.</p>
        ) : quote.error ? (
          <p className="error">{quote.error}</p>
        ) : (
          <>
            <Row label="Regular" value={`${quote.regular_hours} h × ₹${quote.hourly_rate.toFixed(2)}`} />
            {quote.overtime_hours > 0 && (
              <Row label="Overtime" value={`${quote.overtime_hours} h × ₹${quote.overtime_rate.toFixed(2)}`} />
            )}
          </>
        )}
        <div className="flex items-baseline justify-between border-t border-border pt-3 font-semibold">
          <span>Total</span>
          <span className="text-2xl tabular-nums">₹{quote.amount.toFixed(2)}</span>
        </div>
      </div>
      {!quote.error && <ExitForm ticketNo={ticketNo} amount={quote.amount} gates={gates} />}
    </div>
  );
}

function BackLink() {
  return (
    <Link href="/tickets" className="inline-flex items-center gap-1.5 text-sm text-muted hover:text-foreground">
      <Icon name="arrowLeft" className="h-4 w-4" />
      Active tickets
    </Link>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between gap-4">
      <span className="text-muted">{label}</span>
      <span className="text-right font-medium tabular-nums">{value}</span>
    </div>
  );
}

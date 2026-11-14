import { Suspense, type ReactNode } from "react";
import Link from "next/link";
import { notFound } from "next/navigation";
import { pool, query } from "@/lib/db";
import { getFareQuote } from "@/lib/fare";
import { StatusBadge } from "@/components/StatusBadge";
import { Icon } from "@/components/Icon";
import { LicensePlate } from "@/components/LicensePlate";
import { VehicleBadge } from "@/components/VehicleBadge";
import { ThermalReceipt, PrintButton } from "@/components/ThermalReceipt";
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
      <div className="mx-auto max-w-md space-y-5 animate-reveal">
        <div className="no-print flex items-center justify-between">
          <BackLink />
          <PrintButton label="Print Receipt" />
        </div>

        <ThermalReceipt
          ticketNo={ticketNo}
          registrationNo={quote.registration_no}
          typeName={quote.type_name}
          slotNo={quote.slot_no}
          entryTime={quote.entry_time.slice(0, 16)}
          exitTime={receipt?.exit_time}
          gateNumber={receipt?.gate_number}
          totalHours={receipt?.total_hours ?? quote.total_hours}
          amount={receipt?.total_amount ?? quote.amount}
          paymentMode={receipt?.payment_mode}
          paymentStatus={receipt?.payment_status}
          isPaid={true}
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-xl space-y-6 animate-reveal">
      <div className="no-print">
        <BackLink />
      </div>

      <div className="grid gap-6 md:grid-cols-2 items-start">
        {/* Left: Thermal Voucher */}
        <ThermalReceipt
          ticketNo={ticketNo}
          registrationNo={quote.registration_no}
          typeName={quote.type_name}
          slotNo={quote.slot_no}
          entryTime={quote.entry_time.slice(0, 16)}
          exitTime={quote.exit_time.slice(0, 16)}
          totalHours={quote.total_hours}
          regularHours={quote.regular_hours}
          hourlyRate={quote.hourly_rate}
          overtimeHours={quote.overtime_hours}
          overtimeRate={quote.overtime_rate}
          amount={quote.amount}
          passNo={quote.pass_no}
          isPaid={false}
        />

        {/* Right: Checkout & Payment Terminal Form */}
        <div className="space-y-4 no-print">
          <div className="card space-y-3">
            <h2 className="font-bold text-base flex items-center gap-2">
              <Icon name="exit" className="h-5 w-5 text-accent" />
              Process Toll Exit
            </h2>
            <p className="text-xs text-muted">
              Select barrier exit gate and verified payment method to release slot.
            </p>
          </div>

          {!quote.error && (
            <ExitForm ticketNo={ticketNo} amount={quote.amount} gates={gates} />
          )}

          {quote.error && (
            <p className="error">{quote.error}</p>
          )}
        </div>
      </div>
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

function Row({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="flex items-center justify-between gap-4">
      <span className="text-muted">{label}</span>
      <span className="text-right font-medium tabular-nums">{value}</span>
    </div>
  );
}

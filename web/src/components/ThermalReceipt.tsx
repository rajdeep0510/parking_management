"use client";

import { LicensePlate } from "./LicensePlate";
import { VehicleBadge } from "./VehicleBadge";
import { StatusBadge } from "./StatusBadge";

type ThermalReceiptProps = {
  ticketNo: number;
  registrationNo: string;
  typeName: string;
  slotNo: string;
  zoneName?: string;
  entryTime: string;
  exitTime?: string;
  totalHours: number;
  regularHours?: number;
  hourlyRate?: number;
  overtimeHours?: number;
  overtimeRate?: number;
  amount: number;
  passNo?: number | null;
  gateNumber?: string;
  paymentMode?: string | null;
  paymentStatus?: string | null;
  isPaid?: boolean;
};

export function ThermalReceipt({
  ticketNo,
  registrationNo,
  typeName,
  slotNo,
  zoneName,
  entryTime,
  exitTime,
  totalHours,
  regularHours,
  hourlyRate,
  overtimeHours,
  overtimeRate,
  amount,
  passNo,
  gateNumber,
  paymentMode,
  paymentStatus,
  isPaid,
}: ThermalReceiptProps) {
  return (
    <div className="receipt-card relative mx-auto max-w-md bg-surface border border-border/80 rounded-2xl shadow-xl overflow-hidden font-mono text-xs">
      {/* Top Perforated Edge */}
      <div className="h-3 w-full bg-surface-2 border-b border-dashed border-border/80 flex items-center justify-around px-2 text-muted/30 select-none">
        {Array.from({ length: 24 }).map((_, i) => (
          <span key={i} className="text-[10px]">▼</span>
        ))}
      </div>

      <div className="p-6 space-y-4">
        {/* Receipt Header */}
        <div className="text-center space-y-1 border-b border-dashed border-border/80 pb-4">
          <div className="flex items-center justify-center gap-2 mb-1">
            <span className="grid h-6 w-6 place-items-center rounded bg-accent text-white font-bold text-xs">P</span>
            <span className="font-sans font-bold text-sm tracking-tight text-foreground uppercase">
              Central Smart Parking
            </span>
          </div>
          <p className="text-[11px] text-muted">Automated Entry & Exit Toll Terminal</p>
          <div className="inline-block mt-1 font-bold text-foreground text-xs bg-surface-2 px-2.5 py-0.5 rounded-full border border-border">
            TICKET #{ticketNo}
          </div>
        </div>

        {/* Vehicle Information */}
        <div className="space-y-2 text-center py-2 bg-surface-2/50 rounded-xl border border-border/50 p-3">
          <span className="text-[10px] uppercase font-bold text-muted tracking-wider block">
            Vehicle Registration
          </span>
          <div className="flex justify-center">
            <LicensePlate plate={registrationNo} ticketNo={ticketNo} size="lg" />
          </div>
          <div className="flex items-center justify-center gap-2 pt-1">
            <VehicleBadge typeName={typeName} />
            <span className="text-[11px] font-semibold text-muted">
              Slot: <strong className="text-foreground">{slotNo}</strong>
            </span>
          </div>
        </div>

        {/* Audit Details */}
        <div className="space-y-1.5 pt-1 text-[11px]">
          <div className="flex justify-between">
            <span className="text-muted">ENTRY TIME:</span>
            <span className="font-bold tabular-nums text-foreground">{entryTime}</span>
          </div>
          {exitTime && (
            <div className="flex justify-between">
              <span className="text-muted">EXIT TIME:</span>
              <span className="font-bold tabular-nums text-foreground">{exitTime}</span>
            </div>
          )}
          {gateNumber && (
            <div className="flex justify-between">
              <span className="text-muted">GATE TERMINAL:</span>
              <span className="font-bold text-foreground">{gateNumber}</span>
            </div>
          )}
          <div className="flex justify-between border-t border-dashed border-border/80 pt-1.5">
            <span className="text-muted">DURATION BILLED:</span>
            <span className="font-bold text-foreground tabular-nums">{totalHours} hours</span>
          </div>
          {regularHours !== undefined && hourlyRate !== undefined && (
            <div className="flex justify-between text-muted text-[10px]">
              <span>Base ({regularHours}h × ₹{hourlyRate.toFixed(2)}):</span>
              <span className="tabular-nums">₹{(regularHours * hourlyRate).toFixed(2)}</span>
            </div>
          )}
          {overtimeHours !== undefined && overtimeRate !== undefined && overtimeHours > 0 && (
            <div className="flex justify-between text-muted text-[10px]">
              <span>Overtime ({overtimeHours}h × ₹{overtimeRate.toFixed(2)}):</span>
              <span className="tabular-nums">₹{(overtimeHours * overtimeRate).toFixed(2)}</span>
            </div>
          )}
        </div>

        {/* Membership Pass Notice */}
        {passNo && (
          <div className="rounded-lg bg-emerald-500/10 border border-emerald-500/20 p-2 text-center text-emerald-700 dark:text-emerald-400 font-sans font-medium text-xs">
            ✓ Active Permit #{passNo} Applied — No Fee Due
          </div>
        )}

        {/* Payment Total */}
        <div className="border-t-2 border-dashed border-border pt-3 flex items-baseline justify-between font-sans">
          <span className="font-bold text-sm text-foreground uppercase tracking-tight">
            {isPaid ? "Amount Paid" : "Total Due"}
          </span>
          <span className="text-2xl font-black tabular-nums text-foreground">
            ₹{amount.toFixed(2)}
          </span>
        </div>

        {paymentMode && (
          <div className="flex items-center justify-between text-[11px] bg-surface-2 p-2 rounded-lg text-muted">
            <span>Payment Mode: <strong>{paymentMode}</strong></span>
            {paymentStatus && <StatusBadge value={paymentStatus} />}
          </div>
        )}

        {/* Simulated Barcode */}
        <div className="text-center pt-2 space-y-1">
          <div className="flex justify-center items-center gap-0.5 h-10 overflow-hidden opacity-85">
            {[2, 1, 3, 1, 1, 4, 2, 1, 3, 2, 1, 4, 1, 3, 2, 1, 1, 4, 2, 1, 3, 1, 2, 3, 1, 4, 2, 1, 2, 3].map((w, idx) => (
              <span
                key={idx}
                className="bg-foreground inline-block h-full"
                style={{ width: `${w}px` }}
              />
            ))}
          </div>
          <span className="text-[10px] tracking-widest text-muted">
            *TKT-{ticketNo}-{registrationNo.replace(/[^A-Z0-9]/gi, "")}*
          </span>
        </div>

        {/* Footer */}
        <div className="text-center text-[10px] text-muted border-t border-dashed border-border/80 pt-3 space-y-0.5 font-sans">
          <p>Thank you for parking with us!</p>
          <p>Keep ticket for gate barrier scanning</p>
        </div>
      </div>

      {/* Bottom Perforated Edge */}
      <div className="h-3 w-full bg-surface-2 border-t border-dashed border-border/80 flex items-center justify-around px-2 text-muted/30 select-none">
        {Array.from({ length: 24 }).map((_, i) => (
          <span key={i} className="text-[10px]">▲</span>
        ))}
      </div>
    </div>
  );
}

export function PrintButton({ label = "Print Slip", className = "" }: { label?: string; className?: string }) {
  return (
    <button
      type="button"
      onClick={() => window.print()}
      className={`btn text-xs py-1.5 gap-1.5 ${className}`}
    >
      <svg className="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.8}>
        <path d="M6 9V2h12v7M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2" />
        <path d="M6 14h12v8H6z" />
      </svg>
      {label}
    </button>
  );
}

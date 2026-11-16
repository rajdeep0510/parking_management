import { memo } from "react";

type LicensePlateProps = {
  plate: string;
  ticketNo?: number | null;
  size?: "sm" | "md" | "lg";
  className?: string;
  showHSRPBadge?: boolean;
};

export const LicensePlate = memo(function LicensePlate({
  plate,
  ticketNo,
  size = "md",
  className = "",
  showHSRPBadge = true,
}: LicensePlateProps) {
  const formatted = plate.toUpperCase().trim();

  const sizeClasses = {
    sm: "text-[11px] px-1.5 py-0.5 gap-1",
    md: "text-xs px-2 py-0.5 gap-1.5",
    lg: "text-sm px-2.5 py-1 gap-2",
  }[size];

  const notchSizes = {
    sm: "text-[7.5px] px-0.5 py-0.5",
    md: "text-[8.5px] px-1 py-0.5",
    lg: "text-[9.5px] px-1.5 py-1",
  }[size];

  return (
    <span
      className={`inline-flex items-center rounded-md border-2 border-slate-900/90 bg-gradient-to-b from-white via-slate-50 to-slate-200 text-slate-950 shadow-2xs font-mono font-black tracking-widest select-all relative overflow-hidden dark:border-slate-800 dark:from-slate-100 dark:to-slate-300 dark:text-slate-950 transition-all duration-150 hover:shadow-xs active:scale-[0.98] ${sizeClasses} ${className}`}
      title={ticketNo ? `Ticket #${ticketNo} – ${formatted}` : formatted}
    >
      {/* Indian High Security Registration Plate (HSRP) Left Notch */}
      {showHSRPBadge && (
        <span
          className={`-ml-1 -my-0.5 flex flex-col items-center justify-center rounded-l bg-blue-700 text-white font-sans font-black leading-none select-none shrink-0 ${notchSizes}`}
          aria-hidden="true"
        >
          <span className="h-1 w-1 rounded-full bg-amber-400 mb-0.5 opacity-90" />
          <span className="tracking-tighter text-[7.5px] scale-90">IND</span>
        </span>
      )}

      {/* Plate Registration Number */}
      <span className="whitespace-nowrap drop-shadow-[0_1px_0_rgba(255,255,255,0.8)]">
        {formatted}
      </span>

      {/* Tiny corner rivet for tactile metallic feel */}
      <span
        className="h-1 w-1 rounded-full bg-slate-400/80 border border-slate-600/50 shadow-inner ml-0.5 shrink-0 hidden sm:inline-block opacity-70"
        aria-hidden="true"
      />
    </span>
  );
});

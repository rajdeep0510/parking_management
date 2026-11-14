type StatusConfig = {
  badgeClass: string;
  dotClass: string;
  pulse?: boolean;
};

const CONFIGS: Record<string, StatusConfig> = {
  AVAILABLE:   { badgeClass: "badge-green", dotClass: "bg-emerald-500", pulse: true },
  ACTIVE:      { badgeClass: "badge-green", dotClass: "bg-emerald-500", pulse: true },
  SUCCESSFUL:  { badgeClass: "badge-green", dotClass: "bg-emerald-500" },
  OCCUPIED:    { badgeClass: "badge-red", dotClass: "bg-rose-500" },
  FAILED:      { badgeClass: "badge-red", dotClass: "bg-rose-500" },
  CANCELLED:   { badgeClass: "badge-gray", dotClass: "bg-gray-400" },
  INACTIVE:    { badgeClass: "badge-gray", dotClass: "bg-gray-400" },
  EXPIRED:     { badgeClass: "badge-gray", dotClass: "bg-gray-400" },
  COMPLETED:   { badgeClass: "badge-blue", dotClass: "bg-blue-500" },
  MAINTENANCE: { badgeClass: "badge-amber", dotClass: "bg-amber-500", pulse: true },
  PENDING:     { badgeClass: "badge-amber", dotClass: "bg-amber-500", pulse: true },
};

export function StatusBadge({ value }: { value: string }) {
  const conf = CONFIGS[value] ?? { badgeClass: "badge-gray", dotClass: "bg-gray-400" };
  return (
    <span className={`badge ${conf.badgeClass}`}>
      <span
        className={`h-1.5 w-1.5 rounded-full ${conf.dotClass} ${conf.pulse ? "animate-pulse" : ""}`}
        aria-hidden="true"
      />
      {value}
    </span>
  );
}

export function isStatus(value: unknown): value is string {
  return typeof value === "string" && value in CONFIGS;
}

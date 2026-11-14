const COLORS: Record<string, string> = {
  AVAILABLE: "badge-green",
  ACTIVE: "badge-green",
  SUCCESSFUL: "badge-green",
  OCCUPIED: "badge-red",
  FAILED: "badge-red",
  CANCELLED: "badge-gray",
  INACTIVE: "badge-gray",
  EXPIRED: "badge-gray",
  COMPLETED: "badge-blue",
  MAINTENANCE: "badge-amber",
  PENDING: "badge-amber",
};

export function StatusBadge({ value }: { value: string }) {
  return <span className={`badge ${COLORS[value] ?? "badge-gray"}`}>{value}</span>;
}

export function isStatus(value: unknown): value is string {
  return typeof value === "string" && value in COLORS;
}

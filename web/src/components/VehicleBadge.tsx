import { Icon, type IconName } from "./Icon";

type VehicleBadgeProps = {
  typeName: string;
  className?: string;
  showIcon?: boolean;
};

export function VehicleBadge({ typeName, className = "", showIcon = true }: VehicleBadgeProps) {
  const normalized = typeName.toLowerCase();

  let iconName: IconName = "car";
  let styleClasses = "bg-blue-500/10 text-blue-700 dark:text-blue-300 border-blue-500/20";

  if (normalized.includes("electric") || normalized.includes("ev")) {
    iconName = "bolt";
    styleClasses = "bg-emerald-500/10 text-emerald-700 dark:text-emerald-300 border-emerald-500/20";
  } else if (normalized.includes("motorcycle") || normalized.includes("scooter") || normalized.includes("bike")) {
    iconName = "bike";
    styleClasses = "bg-cyan-500/10 text-cyan-700 dark:text-cyan-300 border-cyan-500/20";
  } else if (normalized.includes("commercial") || normalized.includes("truck") || normalized.includes("van")) {
    iconName = "truck";
    styleClasses = "bg-amber-500/10 text-amber-700 dark:text-amber-300 border-amber-500/20";
  } else if (normalized.includes("suv") || normalized.includes("sedan") || normalized.includes("hatchback")) {
    iconName = "car";
    styleClasses = "bg-indigo-500/10 text-indigo-700 dark:text-indigo-300 border-indigo-500/20";
  }

  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-md border px-2 py-0.5 text-xs font-medium tracking-tight whitespace-nowrap shadow-2xs ${styleClasses} ${className}`}
    >
      {showIcon && <Icon name={iconName} className="h-3.5 w-3.5 shrink-0 opacity-80" />}
      {typeName}
    </span>
  );
}

// Allowed values from the CHECK constraints in parking_schema.sql
export const SLOT_STATUS = ["AVAILABLE", "OCCUPIED", "MAINTENANCE"] as const;
export const GATE_TYPE = ["ENTRY", "EXIT"] as const;
export const GATE_STATUS = ["ACTIVE", "INACTIVE"] as const;
export const TICKET_STATUS = ["ACTIVE", "COMPLETED", "CANCELLED"] as const;
export const PASS_STATUS = ["ACTIVE", "EXPIRED", "CANCELLED"] as const;
export const DAY_TYPE = ["WEEKDAY", "WEEKEND", "HOLIDAY"] as const;
export const PAYMENT_MODE = ["CASH", "CARD", "UPI"] as const;
export const PAYMENT_STATUS = ["SUCCESSFUL", "PENDING", "FAILED"] as const;

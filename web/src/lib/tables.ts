import type { PoolClient } from "pg";
import {
  DAY_TYPE,
  GATE_STATUS,
  GATE_TYPE,
  PASS_STATUS,
  SLOT_STATUS,
} from "./enums";

export type FieldType = "text" | "number" | "date" | "time" | "textarea" | "select";

export type Field = {
  name: string;
  label: string;
  type: FieldType;
  required?: boolean;
  step?: string;
  /** Fixed choices (CHECK constraint values). */
  options?: readonly string[];
  /** SQL returning (value, label) rows for a foreign-key dropdown. */
  lookup?: string;
  hint?: string;
};

export type TableConfig = {
  table: string;
  pk: string;
  title: string;
  path: string;
  fields: Field[];
  /** SELECT used for the list view; must include the pk column. */
  listSql: string;
  columns: { key: string; label: string }[];
  /** Optional hook to fill derived values before insert/update. */
  beforeSave?: (values: Record<string, unknown>, client: PoolClient) => Promise<void>;
};

const lookups = {
  vehicleType: "SELECT type_id AS value, type_name AS label FROM vehicle_type ORDER BY type_name",
  zone: "SELECT zone_id AS value, zone_name AS label FROM parking_zone ORDER BY zone_name",
  slotType: "SELECT slot_type_id AS value, slot_type_name AS label FROM slot_type ORDER BY slot_type_name",
  gate: "SELECT gate_id AS value, gate_number || ' (' || gate_type || ')' AS label FROM parking_gate ORDER BY gate_number",
  staff: "SELECT staff_id AS value, staff_name || ' – ' || designation AS label FROM staff_details ORDER BY staff_name",
  member: "SELECT member_id AS value, member_name AS label FROM pass_holder ORDER BY member_name",
  vehicle: "SELECT vehicle_id AS value, registration_no AS label FROM vehicle ORDER BY registration_no",
  plan: "SELECT plan_id AS value, plan_name || ' (' || duration_days || ' days)' AS label FROM membership_plan ORDER BY plan_name",
};

export const TABLES = {
  vehicle_type: {
    table: "vehicle_type",
    pk: "type_id",
    title: "Vehicle Types",
    path: "/vehicle-types",
    fields: [{ name: "type_name", label: "Type name", type: "text", required: true }],
    listSql: "SELECT * FROM vehicle_type ORDER BY type_id",
    columns: [
      { key: "type_id", label: "ID" },
      { key: "type_name", label: "Type" },
    ],
  },
  vehicle: {
    table: "vehicle",
    pk: "vehicle_id",
    title: "Vehicles",
    path: "/vehicles",
    fields: [
      { name: "registration_no", label: "Registration no.", type: "text", required: true },
      { name: "type_id", label: "Vehicle type", type: "select", lookup: lookups.vehicleType, required: true },
      { name: "owner_name", label: "Owner name", type: "text" },
      { name: "owner_phone", label: "Owner phone", type: "text" },
    ],
    listSql: `SELECT v.*, vt.type_name FROM vehicle v
              JOIN vehicle_type vt ON vt.type_id = v.type_id ORDER BY v.vehicle_id`,
    columns: [
      { key: "vehicle_id", label: "ID" },
      { key: "registration_no", label: "Registration" },
      { key: "type_name", label: "Type" },
      { key: "owner_name", label: "Owner" },
      { key: "owner_phone", label: "Phone" },
    ],
  },
  parking_zone: {
    table: "parking_zone",
    pk: "zone_id",
    title: "Zones",
    path: "/zones",
    fields: [
      { name: "zone_name", label: "Zone name", type: "text", required: true },
      { name: "floor_level", label: "Floor level", type: "number", required: true },
      { name: "total_capacity", label: "Total capacity", type: "number", required: true },
    ],
    listSql: "SELECT * FROM parking_zone ORDER BY zone_id",
    columns: [
      { key: "zone_id", label: "ID" },
      { key: "zone_name", label: "Name" },
      { key: "floor_level", label: "Floor" },
      { key: "total_capacity", label: "Capacity" },
    ],
  },
  slot_type: {
    table: "slot_type",
    pk: "slot_type_id",
    title: "Slot Types",
    path: "/slot-types",
    fields: [
      { name: "slot_type_name", label: "Name", type: "text", required: true },
      { name: "description", label: "Description", type: "textarea" },
    ],
    listSql: "SELECT * FROM slot_type ORDER BY slot_type_id",
    columns: [
      { key: "slot_type_id", label: "ID" },
      { key: "slot_type_name", label: "Name" },
      { key: "description", label: "Description" },
    ],
  },
  parking_slot: {
    table: "parking_slot",
    pk: "slot_id",
    title: "Manage Slots",
    path: "/slots/manage",
    fields: [
      { name: "slot_no", label: "Slot no.", type: "text", required: true },
      { name: "zone_id", label: "Zone", type: "select", lookup: lookups.zone, required: true },
      { name: "slot_type_id", label: "Slot type", type: "select", lookup: lookups.slotType, required: true },
      { name: "availability_status", label: "Status", type: "select", options: SLOT_STATUS, required: true },
    ],
    listSql: `SELECT s.*, z.zone_name, st.slot_type_name FROM parking_slot s
              JOIN parking_zone z ON z.zone_id = s.zone_id
              JOIN slot_type st ON st.slot_type_id = s.slot_type_id ORDER BY s.slot_no`,
    columns: [
      { key: "slot_id", label: "ID" },
      { key: "slot_no", label: "Slot" },
      { key: "zone_name", label: "Zone" },
      { key: "slot_type_name", label: "Type" },
      { key: "availability_status", label: "Status" },
    ],
  },
  parking_gate: {
    table: "parking_gate",
    pk: "gate_id",
    title: "Gates",
    path: "/gates",
    fields: [
      { name: "gate_number", label: "Gate number", type: "text", required: true },
      { name: "gate_type", label: "Gate type", type: "select", options: GATE_TYPE, required: true },
      { name: "zone_id", label: "Zone", type: "select", lookup: lookups.zone, required: true },
      { name: "status", label: "Status", type: "select", options: GATE_STATUS, required: true },
    ],
    listSql: `SELECT g.*, z.zone_name FROM parking_gate g
              JOIN parking_zone z ON z.zone_id = g.zone_id ORDER BY g.gate_id`,
    columns: [
      { key: "gate_id", label: "ID" },
      { key: "gate_number", label: "Gate" },
      { key: "gate_type", label: "Type" },
      { key: "zone_name", label: "Zone" },
      { key: "status", label: "Status" },
    ],
  },
  tariff: {
    table: "tariff",
    pk: "tariff_id",
    title: "Tariffs",
    path: "/tariffs",
    fields: [
      { name: "type_id", label: "Vehicle type", type: "select", lookup: lookups.vehicleType, required: true },
      { name: "day_type", label: "Day type", type: "select", options: DAY_TYPE, required: true },
      { name: "start_time", label: "Start time", type: "time", required: true },
      { name: "end_time", label: "End time", type: "time", required: true },
      { name: "hourly_rate", label: "Hourly rate", type: "number", step: "0.01", required: true },
      { name: "overtime_rate", label: "Overtime rate", type: "number", step: "0.01", required: true },
      { name: "valid_from", label: "Valid from", type: "date", required: true },
      { name: "valid_to", label: "Valid to", type: "date", required: true },
    ],
    listSql: `SELECT t.*, vt.type_name FROM tariff t
              JOIN vehicle_type vt ON vt.type_id = t.type_id ORDER BY t.tariff_id`,
    columns: [
      { key: "tariff_id", label: "ID" },
      { key: "type_name", label: "Vehicle type" },
      { key: "day_type", label: "Day" },
      { key: "start_time", label: "From" },
      { key: "end_time", label: "To" },
      { key: "hourly_rate", label: "Hourly" },
      { key: "overtime_rate", label: "Overtime" },
      { key: "valid_from", label: "Valid from" },
      { key: "valid_to", label: "Valid to" },
    ],
  },
  staff_details: {
    table: "staff_details",
    pk: "staff_id",
    title: "Staff",
    path: "/staff",
    fields: [
      { name: "staff_name", label: "Name", type: "text", required: true },
      { name: "designation", label: "Designation", type: "text", required: true },
      { name: "phone_no", label: "Phone", type: "text", required: true },
      { name: "salary", label: "Salary", type: "number", step: "0.01" },
      { name: "date_of_joining", label: "Date of joining", type: "date", required: true },
    ],
    listSql: "SELECT * FROM staff_details ORDER BY staff_id",
    columns: [
      { key: "staff_id", label: "ID" },
      { key: "staff_name", label: "Name" },
      { key: "designation", label: "Designation" },
      { key: "phone_no", label: "Phone" },
      { key: "salary", label: "Salary" },
      { key: "date_of_joining", label: "Joined" },
    ],
  },
  shift_assignment: {
    table: "shift_assignment",
    pk: "assignment_id",
    title: "Shift Assignments",
    path: "/shifts",
    fields: [
      { name: "staff_id", label: "Staff", type: "select", lookup: lookups.staff, required: true },
      { name: "zone_id", label: "Zone (optional)", type: "select", lookup: lookups.zone },
      { name: "gate_id", label: "Gate (optional)", type: "select", lookup: lookups.gate },
      { name: "shift_date", label: "Shift date", type: "date", required: true },
      { name: "start_time", label: "Start time", type: "time", required: true },
      { name: "end_time", label: "End time", type: "time", required: true },
    ],
    listSql: `SELECT sa.*, sd.staff_name, z.zone_name, g.gate_number FROM shift_assignment sa
              JOIN staff_details sd ON sd.staff_id = sa.staff_id
              LEFT JOIN parking_zone z ON z.zone_id = sa.zone_id
              LEFT JOIN parking_gate g ON g.gate_id = sa.gate_id
              ORDER BY sa.shift_date DESC, sa.start_time`,
    columns: [
      { key: "assignment_id", label: "ID" },
      { key: "staff_name", label: "Staff" },
      { key: "zone_name", label: "Zone" },
      { key: "gate_number", label: "Gate" },
      { key: "shift_date", label: "Date" },
      { key: "start_time", label: "Start" },
      { key: "end_time", label: "End" },
    ],
  },
  pass_holder: {
    table: "pass_holder",
    pk: "member_id",
    title: "Members",
    path: "/members",
    fields: [
      { name: "member_name", label: "Name", type: "text", required: true },
      { name: "contact_no", label: "Contact no.", type: "text", required: true },
      { name: "address", label: "Address", type: "textarea" },
    ],
    listSql: "SELECT * FROM pass_holder ORDER BY member_id",
    columns: [
      { key: "member_id", label: "ID" },
      { key: "member_name", label: "Name" },
      { key: "contact_no", label: "Contact" },
      { key: "address", label: "Address" },
    ],
  },
  membership_plan: {
    table: "membership_plan",
    pk: "plan_id",
    title: "Membership Plans",
    path: "/plans",
    fields: [
      { name: "plan_name", label: "Plan name", type: "text", required: true },
      { name: "duration_days", label: "Duration (days)", type: "number", required: true },
      { name: "price", label: "Price", type: "number", step: "0.01", required: true },
      {
        name: "description",
        label: "Description",
        type: "textarea",
        hint: "First line is the summary; each further line is listed as a feature on the plan card.",
      },
    ],
    listSql: "SELECT * FROM membership_plan ORDER BY plan_id",
    columns: [
      { key: "plan_id", label: "ID" },
      { key: "plan_name", label: "Plan" },
      { key: "duration_days", label: "Days" },
      { key: "price", label: "Price" },
      { key: "description", label: "Description" },
    ],
  },
  membership_pass: {
    table: "membership_pass",
    pk: "pass_no",
    title: "Membership Passes",
    path: "/passes",
    fields: [
      { name: "member_id", label: "Member", type: "select", lookup: lookups.member, required: true },
      { name: "vehicle_id", label: "Vehicle", type: "select", lookup: lookups.vehicle, required: true },
      { name: "plan_id", label: "Plan", type: "select", lookup: lookups.plan, required: true },
      { name: "start_date", label: "Start date", type: "date", required: true },
      { name: "end_date", label: "End date", type: "date", hint: "Leave empty to calculate from the plan duration" },
      { name: "status", label: "Status", type: "select", options: PASS_STATUS, required: true },
    ],
    listSql: `SELECT mp.*, ph.member_name, v.registration_no, pl.plan_name FROM membership_pass mp
              JOIN pass_holder ph ON ph.member_id = mp.member_id
              JOIN vehicle v ON v.vehicle_id = mp.vehicle_id
              JOIN membership_plan pl ON pl.plan_id = mp.plan_id ORDER BY mp.pass_no`,
    columns: [
      { key: "pass_no", label: "Pass" },
      { key: "member_name", label: "Member" },
      { key: "registration_no", label: "Vehicle" },
      { key: "plan_name", label: "Plan" },
      { key: "start_date", label: "Start" },
      { key: "end_date", label: "End" },
      { key: "status", label: "Status" },
    ],
    beforeSave: async (values, client) => {
      if (values.end_date == null && values.plan_id != null && values.start_date != null) {
        const { rows } = await client.query(
          "SELECT ($1::date + duration_days)::text AS end_date FROM membership_plan WHERE plan_id = $2",
          [values.start_date, values.plan_id],
        );
        values.end_date = rows[0]?.end_date ?? null;
      }
    },
  },
} satisfies Record<string, TableConfig>;

export type TableKey = keyof typeof TABLES;

export function getTable(key: string): TableConfig {
  if (!(key in TABLES)) throw new Error(`Unknown table: ${key}`);
  return TABLES[key as TableKey];
}

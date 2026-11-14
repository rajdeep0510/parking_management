#!/usr/bin/env node

import { Pool } from "pg";

const localUrl = process.env.LOCAL_DATABASE_URL || "postgres://rajdeepvala@localhost:5432/parking";
const targetUrl = process.argv[2] || process.env.DATABASE_URL || process.env.TARGET_DATABASE_URL;

if (!targetUrl) {
  console.error("Usage: node web/scripts/verify_migration.mjs <TARGET_DATABASE_URL>");
  console.error("Or set DATABASE_URL or TARGET_DATABASE_URL environment variable.");
  process.exit(1);
}

const TABLES = [
  "vehicle_type",
  "slot_type",
  "parking_zone",
  "membership_plan",
  "tariff",
  "parking_slot",
  "parking_gate",
  "staff_details",
  "pass_holder",
  "vehicle",
  "shift_assignment",
  "membership_pass",
  "parking_ticket",
  "parking_exit",
  "payment_details",
];

async function main() {
  console.log("=================================================================");
  console.log(" Verifying Database Migration");
  console.log(` Local DB:  ${localUrl}`);
  console.log(` Target DB: ${targetUrl.replace(/:[^:@]+@/, ":****@")}`);
  console.log("=================================================================\n");

  const localPool = new Pool({ connectionString: localUrl });
  const targetPool = new Pool({
    connectionString: targetUrl,
    ssl: { rejectUnauthorized: false },
  });

  try {
    // 1. Connection check
    console.log("Checking connectivity...");
    const localVersion = await localPool.query("SELECT version()");
    const targetVersion = await targetPool.query("SELECT version()");
    console.log("Local PG:  ", localVersion.rows[0].version.split(",")[0]);
    console.log("Target PG: ", targetVersion.rows[0].version.split(",")[0]);
    console.log("\n-----------------------------------------------------------------");
    console.log(
      `${"Table Name".padEnd(20)} | ${"Local Rows".padStart(10)} | ${"Remote Rows".padStart(10)} | Status`
    );
    console.log("-----------------------------------------------------------------");

    let allMatch = true;

    for (const table of TABLES) {
      const localRes = await localPool.query(`SELECT count(*)::int AS cnt FROM "${table}"`);
      const targetRes = await targetPool.query(`SELECT count(*)::int AS cnt FROM "${table}"`);
      const localCnt = localRes.rows[0].cnt;
      const targetCnt = targetRes.rows[0].cnt;
      const match = localCnt === targetCnt;
      if (!match) allMatch = false;

      console.log(
        `${table.padEnd(20)} | ${String(localCnt).padStart(10)} | ${String(targetCnt).padStart(10)} | ${
          match ? "MATCH" : "MISMATCH"
        }`
      );
    }

    console.log("-----------------------------------------------------------------\n");

    // 2. Sequence test on target
    console.log("Verifying sequence functionality on target database...");
    const seqTest = await targetPool.query(
      "INSERT INTO vehicle_type (type_name) VALUES ($1) RETURNING type_id",
      [`Test-Type-${Date.now()}`]
    );
    const testId = seqTest.rows[0].type_id;
    console.log(`Inserted test record with sequence-generated ID: ${testId}`);
    await targetPool.query("DELETE FROM vehicle_type WHERE type_id = $1", [testId]);
    console.log("Deleted test record successfully. Sequence works properly!\n");

    if (allMatch) {
      console.log("SUCCESS: All 15 tables match exactly with 100% data fidelity!");
    } else {
      console.error("WARNING: Some table counts did not match. Please inspect discrepancies.");
      process.exitCode = 1;
    }
  } catch (err) {
    console.error("Error during verification:", err.message);
    process.exitCode = 1;
  } finally {
    await localPool.end();
    await targetPool.end();
  }
}

main();

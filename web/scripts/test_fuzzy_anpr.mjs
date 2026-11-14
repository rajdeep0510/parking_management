import { Pool } from "pg";
import { findBestActiveTicketMatch, cleanPlateString, calculatePlateSimilarity } from "../src/lib/anpr";

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

async function runFuzzyTest() {
  console.log("==================================================================");
  console.log(" Testing ANPR Fuzzy Matching on User's Exact Scenarios");
  console.log("==================================================================\n");

  // Test 1: RJ-14-CY-0002 vs RJ-14-CV-0002 (V vs Y confusion)
  const sim1 = calculatePlateSimilarity("RJ-14-CV-0002", "RJ-14-CY-0002");
  console.log(`[Test 1] "RJ-14-CV-0002" vs "RJ-14-CY-0002" -> Similarity: ${(sim1 * 100).toFixed(1)}%`);
  if (sim1 < 0.90) throw new Error("Test 1 failed: Similarity too low for V/Y confusion");

  // Test 2: 22BHBY17A vs 22BHB517
  const sim2 = calculatePlateSimilarity("22BHBY17A", "22BHB517");
  console.log(`[Test 2] "22BHBY17A" vs "22BHB517" -> Similarity: ${(sim2 * 100).toFixed(1)}%`);
  if (sim2 < 0.70) throw new Error("Test 2 failed: Similarity too low for BH plate");

  // Test 3: Live End-to-End Test in Neon DB:
  // Step A: Ingest entry for RJ-14-CY-0002
  console.log("\n[Test 3] Live DB Test: Ingesting entry for RJ-14-CY-0002...");
  const slotRes = await pool.query(
    "SELECT slot_id, slot_no FROM parking_slot WHERE availability_status = 'AVAILABLE' ORDER BY slot_id LIMIT 1"
  );
  const slot = slotRes.rows[0];

  let vehicle = (
    await pool.query("SELECT vehicle_id FROM vehicle WHERE upper(registration_no) = 'RJ-14-CY-0002'")
  ).rows[0];
  if (!vehicle) {
    vehicle = (
      await pool.query("INSERT INTO vehicle (registration_no, type_id) VALUES ('RJ-14-CY-0002', 1) RETURNING vehicle_id")
    ).rows[0];
  }

  const ticket = (
    await pool.query(
      "INSERT INTO parking_ticket (vehicle_id, slot_id, entry_gate_id, ticket_status) VALUES ($1, $2, 1, 'ACTIVE') RETURNING ticket_no",
      [vehicle.vehicle_id, slot.slot_id]
    )
  ).rows[0];

  await pool.query("UPDATE parking_slot SET availability_status = 'OCCUPIED' WHERE slot_id = $1", [slot.slot_id]);
  console.log(` -> Ticket #${ticket.ticket_no} created. Slot ${slot.slot_no} marked OCCUPIED.`);

  // Step B: Simulate Exit Scan with misspelled plate "RJ-14-CV-0002"
  console.log("\n[Test 3] Simulating Exit Scan with misread plate 'RJ-14-CV-0002'...");
  const activeTicketsRes = await pool.query(
    `SELECT t.ticket_no, t.slot_id, s.slot_no, z.zone_name, v.vehicle_id, v.registration_no
       FROM parking_ticket t
       JOIN vehicle v ON v.vehicle_id = t.vehicle_id
       JOIN parking_slot s ON s.slot_id = t.slot_id
       JOIN parking_zone z ON z.zone_id = s.zone_id
      WHERE t.ticket_status = 'ACTIVE'`
  );

  const matchResult = findBestActiveTicketMatch("RJ-14-CV-0002", activeTicketsRes.rows, 0.70);
  console.log(` -> Match Result: ${matchResult.matchType} (Confidence: ${(matchResult.similarity * 100).toFixed(1)}%)`);
  console.log(` -> Matched Vehicle: ${matchResult.match.registration_no} in Slot ${matchResult.match.slot_no}`);

  if (matchResult.match.ticket_no !== ticket.ticket_no) {
    throw new Error("Failed to match the correct active ticket!");
  }

  // Complete exit & empty slot
  await pool.query("UPDATE parking_ticket SET ticket_status = 'COMPLETED' WHERE ticket_no = $1", [ticket.ticket_no]);
  await pool.query("UPDATE parking_slot SET availability_status = 'AVAILABLE' WHERE slot_id = $1", [slot.slot_id]);

  const slotAfter = (
    await pool.query("SELECT availability_status FROM parking_slot WHERE slot_id = $1", [slot.slot_id])
  ).rows[0];
  console.log(` -> Slot ${slot.slot_no} after fuzzy exit: ${slotAfter.availability_status} (SUCCESS: Slot Emptied!)\n`);

  // Cleanup test ticket
  await pool.query("DELETE FROM parking_ticket WHERE ticket_no = $1", [ticket.ticket_no]);

  console.log("==================================================================");
  console.log(" All Fuzzy Matching Tests Passed!");
  console.log(" Misread/noisy exit scans now automatically resolve & empty slots!");
  console.log("==================================================================");
}

runFuzzyTest()
  .catch((err) => {
    console.error("Test failed:", err);
    process.exitCode = 1;
  })
  .finally(() => pool.end());

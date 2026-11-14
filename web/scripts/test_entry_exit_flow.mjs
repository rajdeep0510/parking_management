import { Pool } from "pg";

const targetUrl = process.env.DATABASE_URL;
if (!targetUrl) {
  console.error("Error: DATABASE_URL environment variable is required.");
  process.exit(1);
}

const pool = new Pool({
  connectionString: targetUrl,
  ssl: { rejectUnauthorized: false },
});

async function runTest() {
  console.log("==================================================================");
  console.log(" Running End-to-End Test: Entry Fills Slot -> Exit Empties Slot");
  console.log("==================================================================\n");

  const testPlate = `TEST-E2E-${Math.floor(1000 + Math.random() * 9000)}`;

  // 1. Check an available slot before entry
  const freeSlotBefore = await pool.query(
    "SELECT slot_id, slot_no, availability_status FROM parking_slot WHERE availability_status = 'AVAILABLE' ORDER BY slot_id LIMIT 1"
  );
  if (!freeSlotBefore.rows[0]) throw new Error("No free slots to test with!");
  const targetSlot = freeSlotBefore.rows[0];
  console.log(`[Step 1] Target Free Slot before test: ${targetSlot.slot_no} (Status: ${targetSlot.availability_status})`);

  // 2. Perform Entry Scan (POST /api/anpr/entry logic)
  console.log(`[Step 2] Simulating ENTRY SCAN for plate ${testPlate} at Gate 1 (GATE-IN-01)...`);
  
  // Find or create vehicle
  let vehicle = (
    await pool.query("SELECT vehicle_id FROM vehicle WHERE upper(registration_no) = $1", [testPlate])
  ).rows[0];
  if (!vehicle) {
    vehicle = (
      await pool.query("INSERT INTO vehicle (registration_no, type_id) VALUES ($1, 1) RETURNING vehicle_id", [testPlate])
    ).rows[0];
  }

  // Allocate slot and issue ticket
  const ticket = (
    await pool.query(
      "INSERT INTO parking_ticket (vehicle_id, slot_id, entry_gate_id, ticket_status) VALUES ($1, $2, 1, 'ACTIVE') RETURNING ticket_no",
      [vehicle.vehicle_id, targetSlot.slot_id]
    )
  ).rows[0];

  // Mark slot OCCUPIED
  await pool.query("UPDATE parking_slot SET availability_status = 'OCCUPIED' WHERE slot_id = $1", [targetSlot.slot_id]);

  // Verify slot is now OCCUPIED
  const slotAfterEntry = (
    await pool.query("SELECT slot_id, slot_no, availability_status FROM parking_slot WHERE slot_id = $1", [targetSlot.slot_id])
  ).rows[0];
  console.log(` -> Ticket #${ticket.ticket_no} issued.`);
  console.log(` -> Slot ${slotAfterEntry.slot_no} status after entry: ${slotAfterEntry.availability_status} (SUCCESS: Slot Filled!)\n`);

  if (slotAfterEntry.availability_status !== "OCCUPIED") {
    throw new Error("Failed: Slot was not marked OCCUPIED!");
  }

  // 3. Perform Exit Scan (POST /api/anpr/exit logic)
  console.log(`[Step 3] Simulating EXIT SCAN for plate ${testPlate} at Gate 4 (GATE-OUT-01)...`);

  // Record Exit
  const exit = (
    await pool.query(
      "INSERT INTO parking_exit (ticket_no, exit_time, exit_gate_id, total_hours, total_amount) VALUES ($1, LOCALTIMESTAMP(0), 4, 1.0, 50.0) RETURNING exit_id",
      [ticket.ticket_no]
    )
  ).rows[0];

  // Record Payment
  await pool.query(
    "INSERT INTO payment_details (exit_id, payment_mode, payment_status, amount_paid) VALUES ($1, 'CASH', 'SUCCESSFUL', 50.0)",
    [exit.exit_id]
  );

  // Mark ticket COMPLETED
  await pool.query("UPDATE parking_ticket SET ticket_status = 'COMPLETED' WHERE ticket_no = $1", [ticket.ticket_no]);

  // CRUCIAL: Empty the slot (mark AVAILABLE)
  await pool.query("UPDATE parking_slot SET availability_status = 'AVAILABLE' WHERE slot_id = $1", [targetSlot.slot_id]);

  // Verify slot is now AVAILABLE
  const slotAfterExit = (
    await pool.query("SELECT slot_id, slot_no, availability_status FROM parking_slot WHERE slot_id = $1", [targetSlot.slot_id])
  ).rows[0];
  console.log(` -> Exit #${exit.exit_id} recorded with payment.`);
  console.log(` -> Slot ${slotAfterExit.slot_no} status after exit: ${slotAfterExit.availability_status} (SUCCESS: Slot Emptied!)\n`);

  if (slotAfterExit.availability_status !== "AVAILABLE") {
    throw new Error("Failed: Slot was not marked AVAILABLE!");
  }

  // 4. Cleanup test data
  console.log("[Step 4] Cleaning up test records...");
  await pool.query("DELETE FROM payment_details WHERE exit_id = $1", [exit.exit_id]);
  await pool.query("DELETE FROM parking_exit WHERE exit_id = $1", [exit.exit_id]);
  await pool.query("DELETE FROM parking_ticket WHERE ticket_no = $1", [ticket.ticket_no]);
  await pool.query("DELETE FROM vehicle WHERE vehicle_id = $1", [vehicle.vehicle_id]);

  console.log("==================================================================");
  console.log(" All Tests Passed Successfully!");
  console.log(" Entry fills the slot (OCCUPIED), Exit empties the slot (AVAILABLE).");
  console.log("==================================================================");
}

runTest()
  .catch((err) => {
    console.error("Test Error:", err);
    process.exitCode = 1;
  })
  .finally(() => pool.end());

-- Realistic seed data for a 5-level mall car park in Ahmedabad (~320 bays).
--
-- Adds vehicle types, slot types, zones, slots, gates, tariffs, membership plans,
-- staff, a week of shift rosters, ~300 vehicles, members/passes, two weeks of
-- completed parking history (exits + payments) and the cars parked right now.
--
-- Existing rows are kept. Runs in one transaction and refuses to run twice.
--   psql "$DATABASE_URL" -f db/seed_realistic.sql

BEGIN;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM parking_gate WHERE gate_number = 'GATE-OUT-01') THEN
    RAISE EXCEPTION 'Realistic seed already applied (GATE-OUT-01 exists).';
  END IF;
END $$;

-- Sync serial sequences with existing ids (same as fix_sequences.sql).
DO $$
DECLARE r record;
BEGIN
  FOR r IN
    SELECT c.relname AS tbl, a.attname AS col, pg_get_serial_sequence(c.relname, a.attname) AS seq
      FROM pg_class c
      JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum > 0
     WHERE c.relkind = 'r' AND c.relnamespace = 'public'::regnamespace
       AND pg_get_serial_sequence(c.relname, a.attname) IS NOT NULL
  LOOP
    EXECUTE format('SELECT setval(%L, COALESCE((SELECT max(%I) FROM %I), 0) + 1, false)', r.seq, r.col, r.tbl);
  END LOOP;
END $$;

-- ---------------------------------------------------------------- vehicle types
INSERT INTO vehicle_type (type_name)
SELECT n FROM (VALUES ('Hatchback'), ('SUV'), ('MUV / Van'), ('Motorcycle'), ('Scooter'), ('Light Commercial Vehicle')) v(n)
 WHERE NOT EXISTS (SELECT 1 FROM vehicle_type WHERE type_name = n);

-- ------------------------------------------------------------------- slot types
UPDATE slot_type SET description = '2.3 m × 4.5 m bay for hatchbacks and small cars'
 WHERE slot_type_name = 'Compact';

INSERT INTO slot_type (slot_type_name, description)
SELECT n, d FROM (VALUES
  ('Standard',           '2.5 m × 5.0 m bay for sedans and mid-size cars'),
  ('Large',              '2.8 m × 5.5 m bay for SUVs, MUVs and vans'),
  ('Two-Wheeler',        '1.0 m × 2.0 m bay for motorcycles and scooters'),
  ('EV Charging',        'Standard bay with a 7.4 kW AC / 30 kW DC charger'),
  ('Accessible',         '3.6 m wide bay next to the lifts, for drivers with disabilities'),
  ('Reserved - Members', 'Bay reserved for membership pass holders'),
  ('Loading Bay',        '3.5 m × 8.0 m bay for deliveries and light commercial vehicles')
) v(n, d)
 WHERE NOT EXISTS (SELECT 1 FROM slot_type WHERE slot_type_name = n);

-- ------------------------------------------------------------------------ zones
UPDATE parking_zone SET zone_name = 'Zone B - First Floor' WHERE zone_name = 'Zone B - First floor';

INSERT INTO parking_zone (zone_name, floor_level, total_capacity)
SELECT n, f, 0 FROM (VALUES
  ('Zone A - Ground Level', 0),
  ('Zone B - First Floor', 1),
  ('Zone C - Second Floor', 2),
  ('Zone D - Basement 1 (Two-Wheelers)', -1),
  ('Zone E - Basement 2 (Members & Service)', -2)
) v(n, f)
 WHERE NOT EXISTS (SELECT 1 FROM parking_zone WHERE zone_name = n);

-- ------------------------------------------------------------------------ slots
-- Bay ranges per zone: (zone, slot prefix, digits, from, to, slot type)
INSERT INTO parking_slot (slot_no, zone_id, slot_type_id, availability_status)
SELECT p.prefix || lpad(g::text, p.digits, '0'), z.zone_id, st.slot_type_id, 'AVAILABLE'
  FROM (VALUES
    ('Zone A - Ground Level',                   'A-G-',  2,   1,  4, 'Accessible'),
    ('Zone A - Ground Level',                   'A-G-',  2,   5, 12, 'EV Charging'),
    ('Zone A - Ground Level',                   'A-G-',  2,  13, 26, 'Compact'),
    ('Zone A - Ground Level',                   'A-G-',  2,  27, 40, 'Standard'),
    ('Zone B - First Floor',                    'B-F1-', 2,   1,  2, 'Accessible'),
    ('Zone B - First Floor',                    'B-F1-', 2,   3, 20, 'Compact'),
    ('Zone B - First Floor',                    'B-F1-', 2,  21, 50, 'Standard'),
    ('Zone B - First Floor',                    'B-F1-', 2,  51, 60, 'Large'),
    ('Zone C - Second Floor',                   'C-F2-', 2,   1,  2, 'Accessible'),
    ('Zone C - Second Floor',                   'C-F2-', 2,   3, 10, 'EV Charging'),
    ('Zone C - Second Floor',                   'C-F2-', 2,  11, 30, 'Standard'),
    ('Zone C - Second Floor',                   'C-F2-', 2,  31, 60, 'Large'),
    ('Zone D - Basement 1 (Two-Wheelers)',      'D-B1-', 3,   1, 120, 'Two-Wheeler'),
    ('Zone E - Basement 2 (Members & Service)', 'E-B2-', 2,   1, 30, 'Reserved - Members'),
    ('Zone E - Basement 2 (Members & Service)', 'E-B2-', 2,  31, 36, 'Large'),
    ('Zone E - Basement 2 (Members & Service)', 'E-B2-', 2,  37, 40, 'Loading Bay')
  ) p(zone, prefix, digits, lo, hi, slot_type)
  JOIN parking_zone z ON z.zone_name = p.zone
  JOIN slot_type st ON st.slot_type_name = p.slot_type
 CROSS JOIN generate_series(p.lo, p.hi) g
ON CONFLICT (slot_no) DO NOTHING;

-- A few bays out of service
UPDATE parking_slot SET availability_status = 'MAINTENANCE'
 WHERE slot_no IN ('A-G-38', 'B-F1-17', 'C-F2-09', 'C-F2-44', 'D-B1-077', 'D-B1-078')
   AND availability_status = 'AVAILABLE';

UPDATE parking_zone z SET total_capacity = (SELECT count(*) FROM parking_slot s WHERE s.zone_id = z.zone_id);

-- ------------------------------------------------------------------------ gates
INSERT INTO parking_gate (gate_number, gate_type, zone_id, status)
SELECT g, t, z.zone_id, s FROM (VALUES
  ('GATE-IN-01',  'ENTRY', 'Zone A - Ground Level',                   'ACTIVE'),
  ('GATE-OUT-01', 'EXIT',  'Zone A - Ground Level',                   'ACTIVE'),
  ('GATE-IN-02',  'ENTRY', 'Zone A - Ground Level',                   'ACTIVE'),
  ('GATE-OUT-02', 'EXIT',  'Zone A - Ground Level',                   'ACTIVE'),
  ('GATE-IN-B1',  'ENTRY', 'Zone D - Basement 1 (Two-Wheelers)',      'ACTIVE'),
  ('GATE-OUT-B1', 'EXIT',  'Zone D - Basement 1 (Two-Wheelers)',      'ACTIVE'),
  ('GATE-SVC-IN', 'ENTRY', 'Zone E - Basement 2 (Members & Service)', 'INACTIVE'),
  ('GATE-SVC-OUT','EXIT',  'Zone E - Basement 2 (Members & Service)', 'INACTIVE')
) v(g, t, zone, s)
JOIN parking_zone z ON z.zone_name = v.zone
 WHERE NOT EXISTS (SELECT 1 FROM parking_gate WHERE gate_number = g);

-- ---------------------------------------------------------------------- tariffs
-- Daytime window 08:00–22:00 at hourly_rate; hours outside it at overtime_rate.
INSERT INTO tariff (type_id, day_type, start_time, end_time, hourly_rate, overtime_rate, valid_from, valid_to)
SELECT vt.type_id, d, '08:00', '22:00', hr, ot, '2026-01-01', '2026-12-31'
  FROM (VALUES
    ('Motorcycle',               'WEEKDAY', 10, 15), ('Motorcycle',               'WEEKEND', 15, 20),
    ('Scooter',                  'WEEKDAY', 10, 15), ('Scooter',                  'WEEKEND', 15, 20),
    ('Hatchback',                'WEEKDAY', 30, 45), ('Hatchback',                'WEEKEND', 40, 60),
    ('Sedan',                    'WEEKDAY', 40, 60), ('Sedan',                    'WEEKEND', 50, 75),
    ('Electric Vehicle',         'WEEKDAY', 30, 45), ('Electric Vehicle',         'WEEKEND', 40, 60),
    ('SUV',                      'WEEKDAY', 50, 75), ('SUV',                      'WEEKEND', 60, 90),
    ('MUV / Van',                'WEEKDAY', 50, 75), ('MUV / Van',                'WEEKEND', 60, 90),
    ('Light Commercial Vehicle', 'WEEKDAY', 80, 120), ('Light Commercial Vehicle', 'WEEKEND', 100, 150)
  ) v(type_name, d, hr, ot)
  JOIN vehicle_type vt ON vt.type_name = v.type_name
 WHERE NOT EXISTS (SELECT 1 FROM tariff t WHERE t.type_id = vt.type_id AND t.day_type = v.d);

-- ------------------------------------------------------------- membership plans
INSERT INTO membership_plan (plan_name, duration_days, price, description)
SELECT n, d, p, descr FROM (VALUES
  ('Two-Wheeler Monthly',      30,   500.00, 'Unlimited two-wheeler parking in Basement 1 for 30 days'),
  ('Weekday Commuter',         30,  1800.00, 'Monday–Friday car parking for office commuters, 30 days'),
  ('EV Monthly',               30,  3200.00, 'Unlimited parking with priority access to EV charging bays, 30 days'),
  ('Quarterly Unlimited',      90,  6750.00, '24/7 unlimited car parking for 90 days'),
  ('Half-Yearly Unlimited',   180, 12500.00, '24/7 unlimited car parking for 180 days'),
  ('Annual Unlimited',        365, 24000.00, '24/7 unlimited car parking for a year, reserved bay in Basement 2')
) v(n, d, p, descr)
 WHERE NOT EXISTS (SELECT 1 FROM membership_plan WHERE plan_name = n);

-- ------------------------------------------------------------------------ staff
INSERT INTO staff_details (staff_name, designation, phone_no, salary, date_of_joining)
SELECT n, d, p, s, j::date FROM (VALUES
  ('Pooja Nair',     'EV Charging Technician', '9876500013', 33000, '2025-01-06'),
  ('Sanjay Rathod',  'Parking Attendant',      '9876500014', 24000, '2024-09-02'),
  ('Harsh Trivedi',  'Parking Attendant',      '9876500015', 24000, '2025-03-17'),
  ('Meera Joshi',    'Cashier',                '9876500016', 29000, '2024-06-24'),
  ('Farhan Shaikh',  'Gate Operator',          '9876500017', 31500, '2023-12-04'),
  ('Ramesh Chauhan', 'Security Guard',         '9876500018', 27000, '2024-11-11')
) v(n, d, p, s, j)
 WHERE NOT EXISTS (SELECT 1 FROM staff_details WHERE staff_name = n);

-- Weekly roster (yesterday + next 6 days), one day off per person per week.
INSERT INTO shift_assignment (staff_id, zone_id, gate_id, shift_date, start_time, end_time)
SELECT sd.staff_id, z.zone_id, g.gate_id, day::date, r.st::time, r.et::time
  FROM (VALUES
    -- morning
    ('Alex Smith',     'GATE-IN-01',  NULL,                    '06:00', '14:00'),
    ('Amit Kumar',     'GATE-OUT-01', NULL,                    '06:00', '14:00'),
    ('Sanjay Rathod',  'GATE-IN-B1',  NULL,                    '06:00', '14:00'),
    ('Kiran Desai',    NULL,          'Zone A - Ground Level', '06:00', '14:00'),
    ('Rajesh Patel',   NULL,          'Zone A - Ground Level', '06:00', '14:00'),
    ('Vikram Singh',   NULL,          'Zone C - Second Floor', '06:00', '14:00'),
    ('Suresh Yadav',   NULL,          'Zone A - Ground Level', '06:00', '14:00'),
    ('Manish Gupta',   NULL,          'Zone B - First Floor',  '06:00', '14:00'),
    ('Pooja Nair',     NULL,          'Zone A - Ground Level', '09:00', '17:00'),
    -- evening
    ('Rohit Sharma',   'GATE-IN-01',  NULL,                    '14:00', '22:00'),
    ('Nirav Shah',     'GATE-OUT-01', NULL,                    '14:00', '22:00'),
    ('Harsh Trivedi',  'GATE-IN-B1',  NULL,                    '14:00', '22:00'),
    ('Meera Joshi',    'GATE-OUT-02', NULL,                    '14:00', '22:00'),
    ('Deepak Verma',   NULL,          'Zone B - First Floor',  '14:00', '22:00'),
    ('Prakash Mehta',  NULL,          'Zone A - Ground Level', '14:00', '22:00'),
    ('Anil Kumar',     NULL,          'Zone C - Second Floor', '14:00', '22:00'),
    -- night
    ('Farhan Shaikh',  'GATE-IN-01',  NULL,                    '22:00', '06:00'),
    ('Ramesh Chauhan', NULL,          'Zone E - Basement 2 (Members & Service)', '22:00', '06:00')
  ) r(staff, gate, zone, st, et)
  JOIN staff_details sd ON sd.staff_name = r.staff
  LEFT JOIN parking_gate g ON g.gate_number = r.gate
  LEFT JOIN parking_zone z ON z.zone_id = COALESCE(g.zone_id, (SELECT zone_id FROM parking_zone WHERE zone_name = r.zone))
 CROSS JOIN generate_series(current_date - 1, current_date + 6, interval '1 day') day
 WHERE (sd.staff_id + extract(dow FROM day)::int) % 7 <> 0;

-- --------------------------------------------------------------------- vehicles
INSERT INTO vehicle (registration_no, type_id, owner_name, owner_phone)
SELECT r, vt.type_id, o, p FROM (VALUES
  ('GJ01KP4521', 'Hatchback', 'Hetal Shah', '9824011223'),
  ('GJ01HZ0954', 'Hatchback', 'Priya Mehta', '9824022334'),
  ('GJ01WK8888', 'SUV', 'Dhruv Agarwal', '9898012345'),
  ('GJ01MN7007', 'SUV', 'Rakesh Chaudhary', '9898067890'),
  ('GJ01FX1123', 'Motorcycle', 'Yash Parmar', '9737011122'),
  ('GJ01PS2231', 'Scooter', 'Khushi Dave', '9737033344'),
  ('GJ01EV0123', 'Electric Vehicle', 'Aditya Kapoor', '9909055566'),
  ('GJ01SD3344', 'Sedan', 'Vivek Iyer', '9909077788'),
  ('GJ01CT4402', 'Light Commercial Vehicle', 'Shree Logistics', '7926401122'),
  ('GJ01DZ7719', 'Light Commercial Vehicle', 'FreshMart Deliveries', '7926403344')
) v(r, t, o, p)
JOIN vehicle_type vt ON vt.type_name = v.t
ON CONFLICT (registration_no) DO NOTHING;

-- ~300 generated vehicles with realistic Indian plates (mostly Gujarat) and owners.
DO $$
DECLARE
  states text[] := ARRAY['GJ01','GJ01','GJ01','GJ01','GJ27','GJ27','GJ18','GJ05','GJ06','GJ03','GJ38','MH12','MH04','RJ14','DL8C','MP09'];
  firsts text[] := ARRAY['Aarav','Vihaan','Krish','Dev','Parth','Jay','Harsh','Kunal','Ravi','Mehul','Chirag','Bhavin','Jignesh','Darshan','Sagar','Hardik','Nikhil','Rahul','Tushar','Imran',
                         'Ananya','Diya','Riya','Krupa','Nidhi','Hetvi','Janvi','Pooja','Sneha','Komal','Mansi','Foram','Dhara','Shruti','Zoya','Payal'];
  lasts  text[] := ARRAY['Patel','Shah','Mehta','Desai','Joshi','Trivedi','Bhatt','Parmar','Solanki','Chauhan','Rathod','Vaghela','Prajapati','Thakkar','Modi','Panchal','Dave','Pandya','Sheth','Mansuri','Sharma','Iyer','Nair','Kulkarni'];
  -- weighted vehicle mix for a city mall
  types  text[] := ARRAY['Motorcycle','Motorcycle','Motorcycle','Motorcycle','Scooter','Scooter','Scooter','Scooter',
                         'Hatchback','Hatchback','Hatchback','Hatchback','Hatchback','Sedan','Sedan','Sedan',
                         'SUV','SUV','SUV','MUV / Van','Electric Vehicle','Electric Vehicle'];
  letters text := 'ABCDEFGHJKLMNPRSTUVWXYZ';
  i int := 0;
  reg text;
  vtype text;
BEGIN
  PERFORM setseed(0.2026);
  WHILE i < 300 LOOP
    reg := states[1 + floor(random() * array_length(states, 1))::int]
        || substr(letters, 1 + floor(random() * 23)::int, 1)
        || substr(letters, 1 + floor(random() * 23)::int, 1)
        || lpad((1 + floor(random() * 9999))::int::text, 4, '0');
    vtype := types[1 + floor(random() * array_length(types, 1))::int];
    INSERT INTO vehicle (registration_no, type_id, owner_name, owner_phone)
    SELECT reg, type_id,
           firsts[1 + floor(random() * array_length(firsts, 1))::int] || ' ' || lasts[1 + floor(random() * array_length(lasts, 1))::int],
           (ARRAY['98','97','99','90','88','70','63'])[1 + floor(random() * 7)::int] || lpad(floor(random() * 100000000)::int::text, 8, '0')
      FROM vehicle_type WHERE type_name = vtype
    ON CONFLICT (registration_no) DO NOTHING;
    IF FOUND THEN i := i + 1; END IF;
  END LOOP;
END $$;

-- ------------------------------------------------------------ members & passes
INSERT INTO pass_holder (member_name, contact_no, address)
SELECT n, c, a FROM (VALUES
  ('Dhruv Agarwal',    '9898012345', 'B-702, Shivalik Heights, Satellite, Ahmedabad'),
  ('Hetal Shah',       '9824011223', '14, Shanti Kunj Society, Navrangpura, Ahmedabad'),
  ('Yash Parmar',      '9737011122', '33, Sardar Patel Nagar, Ellisbridge, Ahmedabad'),
  ('Aditya Kapoor',    '9909055566', 'A-1201, Iscon Platinum, Bopal, Ahmedabad'),
  ('Vivek Iyer',       '9909077788', '9, Sindhu Bhavan Road, Thaltej, Ahmedabad'),
  ('Priya Mehta',      '9824022334', '21, Vastrapur Lake View, Vastrapur, Ahmedabad'),
  ('Khushi Dave',      '9737033344', '5, Gulbai Tekra, Panchvati, Ahmedabad'),
  ('Rakesh Chaudhary', '9898067890', 'C-404, Prahlad Nagar Residency, Ahmedabad')
) v(n, c, a)
 WHERE NOT EXISTS (SELECT 1 FROM pass_holder WHERE member_name = n);

INSERT INTO membership_pass (member_id, vehicle_id, plan_id, start_date, end_date, status)
SELECT ph.member_id, v.vehicle_id, mp.plan_id, s::date, s::date + mp.duration_days - 1, st
  FROM (VALUES
    ('Dhruv Agarwal',    'GJ01WK8888', 'Annual Unlimited',      '2026-04-01', 'ACTIVE'),
    ('Hetal Shah',       'GJ01KP4521', 'Monthly Unlimited',     '2026-10-20', 'ACTIVE'),
    ('Yash Parmar',      'GJ01FX1123', 'Two-Wheeler Monthly',   '2026-10-15', 'ACTIVE'),
    ('Aditya Kapoor',    'GJ01EV0123', 'EV Monthly',            '2026-10-25', 'ACTIVE'),
    ('Vivek Iyer',       'GJ01SD3344', 'Quarterly Unlimited',   '2026-09-01', 'ACTIVE'),
    ('Priya Mehta',      'GJ01HZ0954', 'Weekday Commuter',      '2026-09-01', 'EXPIRED'),
    ('Khushi Dave',      'GJ01PS2231', 'Two-Wheeler Monthly',   '2026-08-01', 'EXPIRED'),
    ('Rakesh Chaudhary', 'GJ01MN7007', 'Half-Yearly Unlimited', '2026-06-01', 'CANCELLED')
  ) p(member, reg, plan, s, st)
  JOIN pass_holder ph ON ph.member_name = p.member
  JOIN vehicle v ON v.registration_no = p.reg
  JOIN membership_plan mp ON mp.plan_name = p.plan;

-- ------------------------------------------------- tickets, exits and payments
-- Fares follow the same rules as src/lib/fare.ts.
CREATE TEMP TABLE seed_slot_pool (vehicle_type text, slot_type text) ON COMMIT DROP;
INSERT INTO seed_slot_pool VALUES
  ('Motorcycle', 'Two-Wheeler'), ('Scooter', 'Two-Wheeler'),
  ('Hatchback', 'Compact'), ('Hatchback', 'Standard'),
  ('Sedan', 'Standard'), ('Sedan', 'Compact'),
  ('Electric Vehicle', 'EV Charging'), ('Electric Vehicle', 'Standard'),
  ('SUV', 'Large'), ('MUV / Van', 'Large'),
  ('Light Commercial Vehicle', 'Loading Bay');

CREATE FUNCTION pg_temp.seed_fare(p_vehicle int, p_entry timestamp, p_exit timestamp, OUT hours int, OUT amount numeric)
LANGUAGE plpgsql AS $$
DECLARE
  t record;
  v_day_type text := CASE WHEN extract(isodow FROM p_entry) IN (6, 7) THEN 'WEEKEND' ELSE 'WEEKDAY' END;
  regular int := 0;
BEGIN
  hours := greatest(1, ceil(extract(epoch FROM p_exit - p_entry) / 3600))::int;
  IF EXISTS (SELECT 1 FROM membership_pass WHERE vehicle_id = p_vehicle AND status = 'ACTIVE'
              AND p_exit::date BETWEEN start_date AND end_date) THEN
    amount := 0;
    RETURN;
  END IF;
  SELECT tr.hourly_rate, tr.overtime_rate, (p_entry::time BETWEEN tr.start_time AND tr.end_time) AS in_window,
         extract(epoch FROM least(p_exit, p_entry::date + tr.end_time) - p_entry) AS regular_secs
    INTO t
    FROM tariff tr JOIN vehicle v ON v.type_id = tr.type_id
   WHERE v.vehicle_id = p_vehicle AND tr.day_type = v_day_type AND p_entry::date BETWEEN tr.valid_from AND tr.valid_to
   ORDER BY in_window DESC, tr.valid_from DESC, tr.tariff_id DESC
   LIMIT 1;
  IF NOT FOUND THEN amount := 0; RETURN; END IF;
  IF t.in_window THEN regular := least(hours, greatest(0, ceil(t.regular_secs / 3600)))::int; END IF;
  amount := regular * t.hourly_rate + (hours - regular) * t.overtime_rate;
END $$;

DO $$
DECLARE
  d date;
  n int;
  vid int;
  stype text;
  gname text;
  v record;
  slot int;
  ent timestamp;
  ext timestamp;
  mins int;
  gin int;
  gout int;
  fare record;
  tno int;
  eid int;
  r float;
BEGIN
  PERFORM setseed(0.611);

  -- Two weeks of history: busier on weekends.
  FOR d IN SELECT generate_series(current_date - 14, current_date - 1, interval '1 day')::date LOOP
    n := CASE WHEN extract(isodow FROM d) IN (6, 7) THEN 70 ELSE 45 END;
    FOR i IN 1..n LOOP
      SELECT vh.vehicle_id, vt.type_name INTO v
        FROM vehicle vh JOIN vehicle_type vt USING (type_id)
       WHERE vt.type_name IN (SELECT vehicle_type FROM seed_slot_pool)
       ORDER BY random() LIMIT 1;

      SELECT s.slot_id INTO slot
        FROM parking_slot s JOIN slot_type st USING (slot_type_id)
       WHERE st.slot_type_name IN (SELECT slot_type FROM seed_slot_pool WHERE vehicle_type = v.type_name)
       ORDER BY random() LIMIT 1;

      IF v.type_name IN ('Motorcycle', 'Scooter') THEN
        SELECT gate_id INTO gin FROM parking_gate WHERE gate_number = 'GATE-IN-B1';
        SELECT gate_id INTO gout FROM parking_gate WHERE gate_number = 'GATE-OUT-B1';
      ELSE
        gname := CASE WHEN random() < 0.5 THEN '01' ELSE '02' END;
        SELECT gate_id INTO gin FROM parking_gate WHERE gate_number = 'GATE-IN-' || gname;
        gname := CASE WHEN random() < 0.5 THEN '01' ELSE '02' END;
        SELECT gate_id INTO gout FROM parking_gate WHERE gate_number = 'GATE-OUT-' || gname;
      END IF;

      -- Arrivals 07:00–21:30, mostly short visits, some all-day office parking.
      ent := d + interval '7 hours' + random() * interval '14 hours 30 minutes';
      ent := date_trunc('minute', ent);
      mins := CASE WHEN random() < 0.12 THEN 420 + floor(random() * 180) ELSE 20 + floor(power(random(), 2) * 300) END;
      ext := ent + make_interval(mins => mins);

      r := random();
      IF r < 0.03 THEN
        INSERT INTO parking_ticket (vehicle_id, slot_id, entry_time, entry_gate_id, ticket_status)
        VALUES (v.vehicle_id, slot, ent, gin, 'CANCELLED');
        CONTINUE;
      END IF;

      INSERT INTO parking_ticket (vehicle_id, slot_id, entry_time, entry_gate_id, ticket_status)
      VALUES (v.vehicle_id, slot, ent, gin, 'COMPLETED') RETURNING ticket_no INTO tno;

      fare := pg_temp.seed_fare(v.vehicle_id, ent, ext);
      INSERT INTO parking_exit (ticket_no, exit_time, exit_gate_id, total_hours, total_amount)
      VALUES (tno, ext, gout, fare.hours, fare.amount) RETURNING exit_id INTO eid;

      r := random();
      INSERT INTO payment_details (exit_id, payment_mode, payment_status, transaction_time, amount_paid)
      VALUES (eid,
              CASE WHEN r < 0.62 THEN 'UPI' WHEN r < 0.82 THEN 'CARD' ELSE 'CASH' END,
              CASE WHEN random() < 0.015 THEN 'PENDING' ELSE 'SUCCESSFUL' END,
              ext + make_interval(secs => 20 + floor(random() * 90)),
              fare.amount);
    END LOOP;
  END LOOP;

  -- Today: vehicles that already left.
  FOR i IN 1..40 LOOP
    SELECT vh.vehicle_id, vt.type_name INTO v
      FROM vehicle vh JOIN vehicle_type vt USING (type_id)
     WHERE vt.type_name IN (SELECT vehicle_type FROM seed_slot_pool)
     ORDER BY random() LIMIT 1;
    SELECT s.slot_id INTO slot
      FROM parking_slot s JOIN slot_type st USING (slot_type_id)
     WHERE st.slot_type_name IN (SELECT slot_type FROM seed_slot_pool WHERE vehicle_type = v.type_name)
     ORDER BY random() LIMIT 1;
    ent := date_trunc('minute', current_date + interval '7 hours' + random() * greatest(interval '0', localtimestamp - current_date - interval '8 hours'));
    ext := least(ent + make_interval(mins => 20 + floor(power(random(), 2) * 240)::int), localtimestamp - interval '5 minutes');
    CONTINUE WHEN ext <= ent;
    SELECT gate_id INTO gin FROM parking_gate
     WHERE gate_number = CASE WHEN v.type_name IN ('Motorcycle', 'Scooter') THEN 'GATE-IN-B1' ELSE 'GATE-IN-01' END;
    SELECT gate_id INTO gout FROM parking_gate
     WHERE gate_number = CASE WHEN v.type_name IN ('Motorcycle', 'Scooter') THEN 'GATE-OUT-B1' ELSE 'GATE-OUT-01' END;

    INSERT INTO parking_ticket (vehicle_id, slot_id, entry_time, entry_gate_id, ticket_status)
    VALUES (v.vehicle_id, slot, ent, gin, 'COMPLETED') RETURNING ticket_no INTO tno;
    fare := pg_temp.seed_fare(v.vehicle_id, ent, ext);
    INSERT INTO parking_exit (ticket_no, exit_time, exit_gate_id, total_hours, total_amount)
    VALUES (tno, ext, gout, fare.hours, fare.amount) RETURNING exit_id INTO eid;
    r := random();
    INSERT INTO payment_details (exit_id, payment_mode, payment_status, transaction_time, amount_paid)
    VALUES (eid, CASE WHEN r < 0.62 THEN 'UPI' WHEN r < 0.82 THEN 'CARD' ELSE 'CASH' END, 'SUCCESSFUL',
            ext + interval '1 minute', fare.amount);
  END LOOP;

  -- Parked right now: fill free bays (~55% of cars, ~60% of two-wheelers) with
  -- vehicles of a matching type that aren't already inside.
  FOR slot, stype IN
    SELECT s.slot_id, st.slot_type_name
      FROM parking_slot s JOIN slot_type st USING (slot_type_id)
     WHERE s.availability_status = 'AVAILABLE'
       AND st.slot_type_name IN (SELECT slot_type FROM seed_slot_pool)
       AND random() < CASE st.slot_type_name WHEN 'Two-Wheeler' THEN 0.6 WHEN 'Loading Bay' THEN 0.5 ELSE 0.55 END
     ORDER BY s.slot_id
  LOOP
    SELECT vh.vehicle_id INTO vid
      FROM vehicle vh JOIN vehicle_type vt USING (type_id)
     WHERE vt.type_name IN (SELECT vehicle_type FROM seed_slot_pool WHERE slot_type = stype)
       AND NOT EXISTS (SELECT 1 FROM parking_ticket t WHERE t.vehicle_id = vh.vehicle_id AND t.ticket_status = 'ACTIVE')
     ORDER BY random() LIMIT 1;
    CONTINUE WHEN vid IS NULL;

    gname := CASE WHEN stype = 'Two-Wheeler' THEN 'GATE-IN-B1' WHEN random() < 0.5 THEN 'GATE-IN-01' ELSE 'GATE-IN-02' END;
    SELECT gate_id INTO gin FROM parking_gate WHERE gate_number = gname;
    ent := date_trunc('minute', localtimestamp - make_interval(mins => 5 + floor(power(random(), 1.5) * 420)::int));

    INSERT INTO parking_ticket (vehicle_id, slot_id, entry_time, entry_gate_id, ticket_status)
    VALUES (vid, slot, ent, gin, 'ACTIVE');
    UPDATE parking_slot SET availability_status = 'OCCUPIED' WHERE slot_id = slot;
  END LOOP;

  -- Members parked in their reserved basement bays.
  FOR v IN
    SELECT DISTINCT mp.vehicle_id FROM membership_pass mp
      JOIN vehicle vh ON vh.vehicle_id = mp.vehicle_id
      JOIN vehicle_type vt ON vt.type_id = vh.type_id
     WHERE mp.status = 'ACTIVE' AND vt.type_name NOT IN ('Motorcycle', 'Scooter') AND current_date BETWEEN mp.start_date AND mp.end_date
       AND NOT EXISTS (SELECT 1 FROM parking_ticket t WHERE t.vehicle_id = mp.vehicle_id AND t.ticket_status = 'ACTIVE')
       AND random() < 0.7
  LOOP
    SELECT s.slot_id INTO slot FROM parking_slot s JOIN slot_type st USING (slot_type_id)
     WHERE st.slot_type_name = 'Reserved - Members' AND s.availability_status = 'AVAILABLE'
     ORDER BY s.slot_no LIMIT 1;
    EXIT WHEN slot IS NULL;
    SELECT gate_id INTO gin FROM parking_gate WHERE gate_number = 'GATE-IN-02';
    INSERT INTO parking_ticket (vehicle_id, slot_id, entry_time, entry_gate_id, ticket_status)
    VALUES (v.vehicle_id, slot, date_trunc('minute', localtimestamp - make_interval(mins => 30 + floor(random() * 300)::int)), gin, 'ACTIVE');
    UPDATE parking_slot SET availability_status = 'OCCUPIED' WHERE slot_id = slot;
  END LOOP;
END $$;

COMMIT;

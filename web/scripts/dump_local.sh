#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_FILE="$ROOT_DIR/web/init/parking_dump.sql"
LOCAL_URL="${LOCAL_DATABASE_URL:-postgres://rajdeepvala@localhost:5432/parking}"

echo "=========================================================="
echo " Dumping local database: $LOCAL_URL"
echo "=========================================================="

TEMP_DUMP="$(mktemp)"

# 1. Run pg_dump excluding owner and privilege statements
pg_dump "$LOCAL_URL" \
  --schema=public \
  --no-owner \
  --no-privileges \
  > "$TEMP_DUMP"

# 2. Sanitize PostgreSQL 18-specific psql syntax
sed -i '' '/^\\restrict/d' "$TEMP_DUMP"
sed -i '' '/^\\unrestrict/d' "$TEMP_DUMP"
sed -i '' 's/^CREATE SCHEMA public;/CREATE SCHEMA IF NOT EXISTS public;/' "$TEMP_DUMP"
sed -i '' 's/^COMMENT ON SCHEMA public/-- COMMENT ON SCHEMA public/' "$TEMP_DUMP"

# 3. Add drop-if-exists table cleanup at top of dump for clean idempotent restores
cat << 'EOF' > "$OUTPUT_FILE"
-- ============================================================================
-- PARKING DATABASE DUMP - SANITIZED FOR SUPABASE
-- ============================================================================
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', 'public', false);

-- Drop existing public tables in reverse-dependency order for idempotent execution
DROP TABLE IF EXISTS public.payment_details CASCADE;
DROP TABLE IF EXISTS public.parking_exit CASCADE;
DROP TABLE IF EXISTS public.parking_ticket CASCADE;
DROP TABLE IF EXISTS public.membership_pass CASCADE;
DROP TABLE IF EXISTS public.shift_assignment CASCADE;
DROP TABLE IF EXISTS public.parking_slot CASCADE;
DROP TABLE IF EXISTS public.parking_gate CASCADE;
DROP TABLE IF EXISTS public.vehicle CASCADE;
DROP TABLE IF EXISTS public.tariff CASCADE;
DROP TABLE IF EXISTS public.membership_plan CASCADE;
DROP TABLE IF EXISTS public.pass_holder CASCADE;
DROP TABLE IF EXISTS public.staff_details CASCADE;
DROP TABLE IF EXISTS public.parking_zone CASCADE;
DROP TABLE IF EXISTS public.slot_type CASCADE;
DROP TABLE IF EXISTS public.vehicle_type CASCADE;

EOF

cat "$TEMP_DUMP" >> "$OUTPUT_FILE"
rm -f "$TEMP_DUMP"

echo "=========================================================="
echo " Dump complete and sanitized: $OUTPUT_FILE"
echo " Total lines: $(wc -l < "$OUTPUT_FILE")"
echo " File size:   $(ls -lh "$OUTPUT_FILE" | awk '{print $5}')"
echo "=========================================================="

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DUMP_FILE="$ROOT_DIR/web/init/parking_dump.sql"
FIX_SEQ_FILE="$ROOT_DIR/fix_sequences.sql"

# Check for Supabase connection string
SUPABASE_URL="${1:-${SUPABASE_DB_URL:-}}"

if [ -z "$SUPABASE_URL" ]; then
  echo "======================================================================"
  echo " Error: Supabase connection URL not provided."
  echo "======================================================================"
  echo " Usage:"
  echo "   $0 \"postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:5432/postgres\""
  echo " or:"
  echo "   export SUPABASE_DB_URL=\"postgresql://postgres.[PROJECT-REF]:[PASSWORD]@...:5432/postgres\""
  echo "   $0"
  echo "======================================================================"
  exit 1
fi

if [ ! -f "$DUMP_FILE" ]; then
  echo "Dump file $DUMP_FILE not found. Running dump_local.sh first..."
  "$SCRIPT_DIR/dump_local.sh"
fi

echo "======================================================================"
echo " 1. Applying sanitized schema and data dump to Supabase..."
echo "======================================================================"
psql "$SUPABASE_URL" -f "$DUMP_FILE"

echo "======================================================================"
echo " 2. Synchronizing auto-increment primary key sequences..."
echo "======================================================================"
psql "$SUPABASE_URL" -f "$FIX_SEQ_FILE"

echo "======================================================================"
echo " Migration successfully applied to Supabase!"
echo " Next step: Update DATABASE_URL in web/.env.local and verify."
echo "======================================================================"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DUMP_FILE="$ROOT_DIR/web/init/parking_dump.sql"
FIX_SEQ_FILE="$ROOT_DIR/fix_sequences.sql"

# Check for Neon DB connection string
NEON_URL="${1:-${NEON_DATABASE_URL:-}}"

if [ -z "$NEON_URL" ]; then
  echo "======================================================================"
  echo " Error: Neon connection URL not provided."
  echo "======================================================================"
  echo " Usage:"
  echo "   $0 \"postgresql://[user]:[password]@[endpoint].neon.tech/[dbname]?sslmode=require\""
  echo " or:"
  echo "   export NEON_DATABASE_URL=\"postgresql://[user]:[password]@[endpoint].neon.tech/[dbname]?sslmode=require\""
  echo "   $0"
  echo "======================================================================"
  exit 1
fi

if [ ! -f "$DUMP_FILE" ]; then
  echo "Dump file $DUMP_FILE not found. Running dump_local.sh first..."
  "$SCRIPT_DIR/dump_local.sh"
fi

echo "======================================================================"
echo " 1. Applying sanitized schema and data dump to Neon DB..."
echo "======================================================================"
psql "$NEON_URL" -f "$DUMP_FILE"

echo "======================================================================"
echo " 2. Synchronizing auto-increment primary key sequences..."
echo "======================================================================"
psql "$NEON_URL" -f "$FIX_SEQ_FILE"

echo "======================================================================"
echo " 3. Running parity verification..."
echo "======================================================================"
node "$SCRIPT_DIR/verify_migration.mjs" "$NEON_URL"

echo "======================================================================"
echo " Neon DB migration & verification complete!"
echo " Next step: Update DATABASE_URL in web/.env.local with your Neon URL."
echo "======================================================================"

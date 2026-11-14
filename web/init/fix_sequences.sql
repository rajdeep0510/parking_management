-- Sync every serial sequence with the max id in its table.
-- Needed when seed rows were inserted with explicit ids, otherwise new INSERTs fail
-- with "duplicate key value violates unique constraint ..._pkey".
-- Safe to run any number of times:  psql -d parking -f fix_sequences.sql

DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT c.relname AS tbl, a.attname AS col, pg_get_serial_sequence(c.relname, a.attname) AS seq
      FROM pg_class c
      JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum > 0
     WHERE c.relkind = 'r' AND c.relnamespace = 'public'::regnamespace
       AND pg_get_serial_sequence(c.relname, a.attname) IS NOT NULL
  LOOP
    EXECUTE format(
      'SELECT setval(%L, COALESCE((SELECT max(%I) FROM %I), 0) + 1, false)',
      r.seq, r.col, r.tbl
    );
    RAISE NOTICE '% -> next %.%', r.seq, r.tbl, r.col;
  END LOOP;
END $$;

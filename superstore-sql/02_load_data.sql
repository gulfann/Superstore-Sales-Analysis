-- ============================================================
-- Superstore Sales Analysis — Load Data
-- Run 01_schema.sql first.
-- ============================================================

-- Option A: psql client with local file access
-- Run from your terminal (not inside psql), adjusting the path to your CSV:
--   psql -d your_database -c "\COPY orders FROM 'superstore_cleaned.csv' WITH (FORMAT csv, HEADER true)"

-- Option B: from inside psql, using the \COPY meta-command
-- (\COPY runs client-side, so it works even if the server can't see your local filesystem)
\COPY orders FROM 'superstore_cleaned.csv' WITH (FORMAT csv, HEADER true)

-- Option C: server-side COPY (requires the CSV to be on the DB server's filesystem
-- and superuser privileges) — use this only if using a local Postgres install
-- where the server process can read the file directly:
-- COPY orders FROM '/absolute/path/to/superstore_cleaned.csv' WITH (FORMAT csv, HEADER true);

-- Verify load
SELECT COUNT(*) AS total_rows FROM orders;               -- expect 9994
SELECT COUNT(DISTINCT order_id) AS total_orders FROM orders;   -- expect 5009
SELECT MIN(order_date), MAX(order_date) FROM orders;     -- expect 2014-01-03 to 2017-12-30

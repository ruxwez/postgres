CREATE EXTENSION pg_duckdb;

-- Queries that touch DuckDB run entirely in DuckDB, which doesn't know
-- assert_true(): fetch the results first, then check them.
SELECT count(*) AS rows FROM duckdb.query($$ SELECT 42 AS answer $$) \gset
SELECT assert_true(:rows = 1, 'pg_duckdb: duckdb.query()');

CREATE TABLE sales (amount int);
INSERT INTO sales SELECT g FROM generate_series(1, 100) g;
SET duckdb.force_execution = true;
SELECT sum(amount) AS total FROM sales \gset
RESET duckdb.force_execution;
SELECT assert_true(:total = 5050, 'pg_duckdb: aggregate executed by DuckDB');

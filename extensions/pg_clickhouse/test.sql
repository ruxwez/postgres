CREATE EXTENSION pg_clickhouse;

-- No ClickHouse server in tests: check the wrapper and that a server can be defined.
CREATE SERVER clickhouse FOREIGN DATA WRAPPER clickhouse_fdw OPTIONS (host 'localhost', port '8123');
SELECT assert_true((SELECT count(*) FROM pg_foreign_server WHERE srvname = 'clickhouse') = 1, 'pg_clickhouse: foreign server');

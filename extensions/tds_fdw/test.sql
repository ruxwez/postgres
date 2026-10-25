CREATE EXTENSION tds_fdw;

-- No SQL Server in tests: check that a server can be defined.
CREATE SERVER mssql FOREIGN DATA WRAPPER tds_fdw OPTIONS (servername '127.0.0.1', port '1433');
SELECT assert_true((SELECT count(*) FROM pg_foreign_server WHERE srvname = 'mssql') = 1, 'tds_fdw: foreign server');

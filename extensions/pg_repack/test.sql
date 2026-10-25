CREATE EXTENSION pg_repack;

SELECT assert_true(repack.version() LIKE 'pg_repack%', 'pg_repack: version()');

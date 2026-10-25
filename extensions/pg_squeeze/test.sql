CREATE EXTENSION pg_squeeze;

SELECT assert_true(to_regclass('squeeze.tables') IS NOT NULL, 'pg_squeeze: squeeze.tables');

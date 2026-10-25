CREATE EXTENSION pg_qualstats;

SELECT assert_true(to_regclass('pg_qualstats') IS NOT NULL, 'pg_qualstats: view');
SELECT assert_true((SELECT count(*) FROM pg_qualstats) >= 0, 'pg_qualstats: view readable');

CREATE EXTENSION pg_stat_monitor;

SELECT 1 + 1;
SELECT assert_true((SELECT count(*) FROM pg_stat_monitor) >= 0, 'pg_stat_monitor: view readable');

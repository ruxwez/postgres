-- Runs in the database set by cron.database_name (see the database file).
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT assert_true(cron.schedule('test-job', '*/5 * * * *', 'SELECT 1') > 0, 'pg_cron: schedule()');
SELECT assert_true((SELECT count(*) FROM cron.job WHERE jobname = 'test-job') = 1, 'pg_cron: job listed');
SELECT assert_true(cron.unschedule('test-job'), 'pg_cron: unschedule()');

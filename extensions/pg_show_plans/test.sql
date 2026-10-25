CREATE EXTENSION pg_show_plans;

SELECT assert_true((SELECT count(*) FROM pg_show_plans WHERE pid = pg_backend_pid()) >= 1, 'pg_show_plans: own query plan visible');

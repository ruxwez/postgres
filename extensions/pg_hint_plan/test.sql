CREATE EXTENSION pg_hint_plan;

SET pg_hint_plan.enable_hint = on;
SELECT assert_true(current_setting('pg_hint_plan.enable_hint') = 'on', 'pg_hint_plan: settings registered');
SELECT assert_true(to_regclass('hint_plan.hints') IS NOT NULL, 'pg_hint_plan: hint table');

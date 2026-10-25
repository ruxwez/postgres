CREATE EXTENSION first_last_agg;

SELECT assert_true((SELECT first(x ORDER BY x) FROM (VALUES (30), (10), (20)) t(x)) = 10, 'first_last_agg: first()');
SELECT assert_true((SELECT last(x ORDER BY x) FROM (VALUES (30), (10), (20)) t(x)) = 30, 'first_last_agg: last()');

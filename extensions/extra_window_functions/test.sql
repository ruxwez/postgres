CREATE EXTENSION extra_window_functions;

SELECT assert_true(
  (SELECT last_value_ignore_nulls(x) OVER (ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
   FROM (VALUES (1, 10), (2, NULL::int)) t(id, x)
   ORDER BY id DESC LIMIT 1) = 10,
  'extra_window_functions: last_value_ignore_nulls()');

CREATE EXTENSION orafce;

SELECT assert_true(oracle.nvl(NULL::text, 'fallback') = 'fallback', 'orafce: nvl()');
SELECT assert_true(oracle.decode(2, 1, 'one', 2, 'two') = 'two', 'orafce: decode()');
SELECT assert_true(oracle.last_day('2024-02-15'::date) = '2024-02-29'::date, 'orafce: last_day()');

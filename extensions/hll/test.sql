CREATE EXTENSION hll;

SELECT assert_true(
  abs(hll_cardinality((SELECT hll_add_agg(hll_hash_integer(g)) FROM generate_series(1, 1000) g)) - 1000) < 50,
  'hll: cardinality estimate within 5%');

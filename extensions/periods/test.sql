CREATE EXTENSION periods CASCADE;

CREATE TABLE prices (id int, valid_from date, valid_to date);
SELECT periods.add_period('prices', 'validity', 'valid_from', 'valid_to');

SELECT assert_true(
  (SELECT count(*) FROM periods.periods WHERE table_name = 'prices'::regclass AND period_name = 'validity') = 1,
  'periods: add_period()');

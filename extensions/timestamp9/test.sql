CREATE EXTENSION timestamp9;

SELECT assert_true(
  timestamp9_to_timestamp(timestamp_to_timestamp9('2020-01-01 12:00:00'::timestamp)) = '2020-01-01 12:00:00'::timestamp,
  'timestamp9: round trip');

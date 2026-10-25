CREATE EXTENSION timescaledb;

CREATE TABLE metrics (time timestamptz NOT NULL, value float8);
SELECT create_hypertable('metrics', by_range('time', interval '1 day'));
INSERT INTO metrics SELECT t, 1 FROM generate_series('2024-01-01'::timestamptz, '2024-01-03', interval '1 hour') t;

SELECT assert_true((SELECT count(*) FROM timescaledb_information.chunks WHERE hypertable_name = 'metrics') = 3, 'timescaledb: one chunk per day');
SELECT assert_true(
  (SELECT count(*) FROM (SELECT time_bucket('1 day', time) FROM metrics GROUP BY 1) b) = 3,
  'timescaledb: time_bucket()');

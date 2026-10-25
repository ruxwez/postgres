-- Runs in the pg_cron database (see the database file): pipelines are pg_cron jobs.
CREATE EXTENSION IF NOT EXISTS pg_incremental CASCADE;
SET client_min_messages = warning;

CREATE TABLE incremental_events (id bigint GENERATED ALWAYS AS IDENTITY, client_id int NOT NULL);
CREATE TABLE incremental_counts (client_id int PRIMARY KEY, events bigint NOT NULL);
INSERT INTO incremental_events (client_id) SELECT g % 10 FROM generate_series(1, 100) g;

-- Processes the existing rows right away.
SELECT incremental.create_sequence_pipeline('count-events', 'incremental_events', $$
  INSERT INTO incremental_counts
  SELECT client_id, count(*) FROM incremental_events WHERE id BETWEEN $1 AND $2 GROUP BY client_id
  ON CONFLICT (client_id) DO UPDATE SET events = incremental_counts.events + excluded.events
$$, schedule := '0 0 1 1 *');
SELECT assert_true((SELECT sum(events) FROM incremental_counts) = 100, 'pg_incremental: initial run');

INSERT INTO incremental_events (client_id) SELECT g % 10 FROM generate_series(1, 50) g;
CALL incremental.execute_pipeline('count-events');
SELECT assert_true((SELECT sum(events) FROM incremental_counts) = 150, 'pg_incremental: only new rows processed');

SELECT incremental.drop_pipeline('count-events');
DROP TABLE incremental_events, incremental_counts;

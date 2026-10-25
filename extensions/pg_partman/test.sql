CREATE SCHEMA partman;
CREATE EXTENSION pg_partman SCHEMA partman;

CREATE TABLE events (id bigint, created_at timestamptz NOT NULL) PARTITION BY RANGE (created_at);
SELECT partman.create_parent('public.events', 'created_at', '1 day');

SELECT assert_true((SELECT count(*) FROM pg_inherits WHERE inhparent = 'events'::regclass) > 1, 'pg_partman: partitions created');

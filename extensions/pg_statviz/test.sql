CREATE EXTENSION pg_statviz;

SELECT pgstatviz.snapshot();
SELECT assert_true((SELECT count(*) FROM pgstatviz.snapshots) > 0, 'pg_statviz: snapshot()');

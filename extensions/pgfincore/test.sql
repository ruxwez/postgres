CREATE EXTENSION pgfincore;

CREATE TABLE cached AS SELECT g FROM generate_series(1, 1000) g;
SELECT assert_true((pgsysconf()).os_page_size > 0, 'pgfincore: pgsysconf()');
SELECT assert_true((SELECT count(*) FROM pgfincore('cached')) > 0, 'pgfincore: pgfincore()');

CREATE EXTENSION pg_stat_statements;
CREATE EXTENSION pg_stat_kcache;

SELECT sum(length(md5(g::text))) FROM generate_series(1, 10000) g;
SELECT assert_true((SELECT count(*) FROM pg_stat_kcache()) > 0, 'pg_stat_kcache: statistics collected');

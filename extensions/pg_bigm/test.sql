CREATE EXTENSION pg_bigm;

CREATE TABLE docs (content text);
INSERT INTO docs VALUES ('PostgreSQL'), ('full text search'), ('bigram index');
CREATE INDEX ON docs USING gin (content gin_bigm_ops);

SELECT assert_true((SELECT count(*) FROM docs WHERE content LIKE '%text%') = 1, 'pg_bigm: LIKE search');
SELECT assert_true(bigm_similarity('PostgreSQL', 'PostgreSQ') > 0.5, 'pg_bigm: bigm_similarity()');

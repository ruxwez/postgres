CREATE EXTENSION pg_similarity;

SELECT assert_true(jaro('martha', 'marhta') > 0.9, 'pg_similarity: jaro()');
SELECT assert_true(lev('hello', 'hello') = 1, 'pg_similarity: lev() of identical strings');

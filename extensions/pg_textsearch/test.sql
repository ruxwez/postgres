CREATE EXTENSION pg_textsearch;

CREATE TABLE articles (id serial PRIMARY KEY, content text NOT NULL);
INSERT INTO articles (content) VALUES
  ('database query optimization techniques'),
  ('machine learning neural network'),
  ('distributed systems consensus protocol');
CREATE INDEX articles_bm25 ON articles USING bm25 (content) WITH (text_config = 'english');

SELECT assert_true(
  (SELECT content FROM articles ORDER BY content <@> to_bm25query('database optimization', 'articles_bm25') LIMIT 1) LIKE '%database%',
  'pg_textsearch: BM25 ranking');

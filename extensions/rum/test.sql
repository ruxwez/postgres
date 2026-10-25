CREATE EXTENSION rum;

CREATE TABLE posts (id int, body tsvector);
INSERT INTO posts VALUES
  (1, to_tsvector('english', 'PostgreSQL is great')),
  (2, to_tsvector('english', 'Full text search')),
  (3, to_tsvector('english', 'RUM index ordering'));
CREATE INDEX ON posts USING rum (body rum_tsvector_ops);

SET enable_seqscan = off;
SELECT assert_true(
  (SELECT id FROM posts WHERE body @@ to_tsquery('english', 'search') ORDER BY body <=> to_tsquery('english', 'search') LIMIT 1) = 2,
  'rum: ranked search');

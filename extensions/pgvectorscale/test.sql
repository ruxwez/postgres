CREATE EXTENSION vectorscale CASCADE;

CREATE TABLE embeddings (id int, embedding vector(3));
INSERT INTO embeddings VALUES (1, '[1,2,3]'), (2, '[4,5,6]'), (3, '[7,8,9]');
CREATE INDEX ON embeddings USING diskann (embedding vector_cosine_ops);

SET enable_seqscan = off;
SELECT assert_true((SELECT id FROM embeddings ORDER BY embedding <=> '[1,2,3]' LIMIT 1) = 1, 'vectorscale: diskann search');

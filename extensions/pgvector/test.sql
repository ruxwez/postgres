CREATE EXTENSION vector;

CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3));
INSERT INTO items (embedding) VALUES ('[1,2,3]'), ('[4,5,6]');
CREATE INDEX ON items USING hnsw (embedding vector_l2_ops);

DO $$
BEGIN
  IF (SELECT id FROM items ORDER BY embedding <-> '[3,1,2]' LIMIT 1) <> 1 THEN
    RAISE EXCEPTION 'pgvector: unexpected nearest neighbour';
  END IF;
END $$;

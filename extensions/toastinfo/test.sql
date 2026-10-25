CREATE EXTENSION toastinfo;

CREATE TABLE blobs (kind text, v text);
INSERT INTO blobs VALUES
  ('small', 'small'),
  ('compressible', repeat('x', 100000)),
  -- Random hex barely compresses, so it's moved out of line to TOAST.
  ('random', (SELECT string_agg(md5(random()::text), '') FROM generate_series(1, 2000)));

SELECT assert_true((SELECT pg_toastinfo(v)::text FROM blobs WHERE kind = 'small') = 'short inline varlena', 'toastinfo: inline value');
SELECT assert_true((SELECT pg_toastinfo(v)::text FROM blobs WHERE kind = 'compressible') LIKE '%compressed%', 'toastinfo: compressed value');
SELECT assert_true((SELECT pg_toastinfo(v)::text FROM blobs WHERE kind = 'random') LIKE 'toasted%', 'toastinfo: toasted value');

CREATE EXTENSION tdigest;

SELECT assert_true(abs((SELECT tdigest_percentile(g, 100, 0.5) FROM generate_series(1, 1000) g) - 500) < 20, 'tdigest: median estimate');

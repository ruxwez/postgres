CREATE EXTENSION hypopg;

CREATE TABLE items AS SELECT g AS id FROM generate_series(1, 10000) g;
ANALYZE items;
SELECT * FROM hypopg_create_index('CREATE INDEX ON items (id)');

SELECT assert_true((SELECT count(*) FROM hypopg()) = 1, 'hypopg: hypothetical index');
SELECT assert_true((SELECT hypopg_relation_size(indexrelid) FROM hypopg()) > 0, 'hypopg: estimated size');

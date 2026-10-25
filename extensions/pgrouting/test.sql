CREATE EXTENSION pgrouting CASCADE;

CREATE TABLE roads (id int, source int, target int, cost float8);
INSERT INTO roads VALUES (1, 1, 2, 1), (2, 2, 3, 2), (3, 1, 3, 5);

SELECT assert_true(
  (SELECT agg_cost FROM pgr_dijkstra('SELECT id, source, target, cost FROM roads', 1, 3) ORDER BY seq DESC LIMIT 1) = 3,
  'pgrouting: shortest path goes through node 2');

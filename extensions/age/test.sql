CREATE EXTENSION age;
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

SELECT create_graph('people');
SELECT * FROM cypher('people', $$
  CREATE (:Person {name: 'Alice'})-[:KNOWS]->(:Person {name: 'Bob'})
$$) AS (v agtype);

SELECT assert_true(
  (SELECT name::text FROM cypher('people', $$
     MATCH (:Person {name: 'Alice'})-[:KNOWS]->(p) RETURN p.name
   $$) AS (name agtype)) = 'Bob',
  'age: Alice should know Bob');

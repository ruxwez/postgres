CREATE EXTENSION pg_graphql;

CREATE TABLE book (id int PRIMARY KEY, title text);
INSERT INTO book VALUES (1, 'Dune');

SELECT assert_true(graphql.resolve($$ { __typename } $$) -> 'data' ->> '__typename' = 'Query', 'pg_graphql: resolve()');
SELECT assert_true(
  graphql.resolve($$ { bookCollection { edges { node { title } } } } $$)
    #>> '{data,bookCollection,edges,0,node,title}' = 'Dune',
  'pg_graphql: query a table');

-- Runs in the pg_cron database (see the database file): documentdb needs pg_cron.
CREATE EXTENSION IF NOT EXISTS documentdb CASCADE;

SELECT documentdb_api.insert_one('library', 'books', '{"title": "Dune"}');
SELECT documentdb_api.insert_one('library', 'books', '{"title": "Neuromancer"}');

SELECT assert_true(
  (SELECT documentdb_core.bson_to_json_string(document) FROM documentdb_api.count_query('library', '{"count": "books"}'))::text
    LIKE '%"n" : { "$numberInt" : "2" }%',
  'documentdb: count documents in a collection');

SELECT documentdb_api.drop_collection('library', 'books');

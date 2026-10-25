-- An output plugin for logical decoding, not an extension.
CREATE TABLE changes (id int PRIMARY KEY);
SELECT pg_create_logical_replication_slot('wal2json_test', 'wal2json');
INSERT INTO changes VALUES (1);

SELECT assert_true(
  (SELECT count(*) FROM pg_logical_slot_get_changes('wal2json_test', NULL, NULL) WHERE data LIKE '%"changes"%') > 0,
  'wal2json: insert decoded as JSON');
SELECT pg_drop_replication_slot('wal2json_test');

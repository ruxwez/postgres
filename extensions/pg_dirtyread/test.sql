CREATE EXTENSION pg_dirtyread;

CREATE TABLE notes (id int) WITH (autovacuum_enabled = false);
INSERT INTO notes VALUES (1), (2);
DELETE FROM notes WHERE id = 2;

SELECT assert_true((SELECT count(*) FROM notes) = 1, 'pg_dirtyread: row deleted');
SELECT assert_true((SELECT count(*) FROM pg_dirtyread('notes') AS t(id int)) = 2, 'pg_dirtyread: deleted row still readable');

CREATE EXTENSION pg_permissions;

CREATE TABLE secrets (id int);
SELECT assert_true((SELECT count(*) FROM table_permissions WHERE object_name = 'secrets') > 0, 'pg_permissions: table_permissions view');

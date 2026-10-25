CREATE EXTENSION pglogical;

SELECT assert_true(pglogical.pglogical_version() IS NOT NULL, 'pglogical: pglogical_version()');
SELECT assert_true(to_regproc('pglogical.create_node') IS NOT NULL, 'pglogical: create_node()');

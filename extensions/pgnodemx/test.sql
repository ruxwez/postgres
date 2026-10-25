CREATE EXTENSION pgnodemx;

SELECT assert_true(cgroup_mode() IS NOT NULL, 'pgnodemx: cgroup_mode()');
SELECT assert_true(envvar_text('PGDATA') IS NOT NULL, 'pgnodemx: envvar_text()');

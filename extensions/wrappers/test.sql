CREATE EXTENSION wrappers;

SELECT assert_true((SELECT count(*) FROM pg_proc WHERE proname LIKE '%\_fdw\_handler') > 0, 'wrappers: FDW handlers');

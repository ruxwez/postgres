CREATE EXTENSION prioritize;

SELECT assert_true(get_backend_priority(pg_backend_pid()) IS NOT NULL, 'prioritize: get_backend_priority()');

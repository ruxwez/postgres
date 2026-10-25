CREATE EXTENSION pgtap;

SELECT plan(2);
SELECT assert_true(ok(1 = 1, 'one equals one') LIKE 'ok%', 'pgtap: ok()');
SELECT assert_true(is(2 + 2, 4) LIKE 'ok%', 'pgtap: is()');
SELECT * FROM finish();

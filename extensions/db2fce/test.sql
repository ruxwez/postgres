CREATE EXTENSION db2fce;

SELECT assert_true(db2.day(DATE '2020-03-15') = 15, 'db2fce: day()');
SELECT assert_true(db2.months_between(DATE '2020-03-15', DATE '2020-01-15') = 2, 'db2fce: months_between()');

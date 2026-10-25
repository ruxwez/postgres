CREATE EXTENSION re2;

SELECT assert_true(re2match('hello world', 'h.*o') AND NOT re2match('hello world', '^xyz'), 're2: re2match()');
SELECT assert_true(re2extract('2024-08-12', '([0-9]{4})') = '2024', 're2: re2extract()');
SELECT assert_true(re2countmatches('a1b2c3', '[0-9]') = 3, 're2: re2countmatches()');

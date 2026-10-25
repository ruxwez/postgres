CREATE EXTENSION anon;

SELECT assert_true(anon.partial('abcdefgh', 2, 'xxxx', 2) = 'abxxxxgh', 'anon: partial()');

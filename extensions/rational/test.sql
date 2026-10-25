CREATE EXTENSION pg_rational;

SELECT assert_true('1/3'::rational + '1/6'::rational = '1/2'::rational, 'pg_rational: addition');

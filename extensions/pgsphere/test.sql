CREATE EXTENSION pg_sphere;

SELECT assert_true(abs((spoint '(0d,0d)' <-> spoint '(90d,0d)') - pi() / 2) < 1e-9, 'pg_sphere: distance on the sphere');

CREATE EXTENSION jsquery;

SELECT assert_true('{"a": {"b": 3}}'::jsonb @@ 'a.b = 3'::jsquery, 'jsquery: nested match');
SELECT assert_true(NOT ('{"a": 2}'::jsonb @@ 'a = 1'::jsquery), 'jsquery: non-match');

CREATE EXTENSION pg_jsonschema;

SELECT assert_true(json_matches_schema('{"type": "object", "properties": {"age": {"type": "integer"}}}', '{"age": 30}'), 'pg_jsonschema: valid document');
SELECT assert_true(NOT json_matches_schema('{"type": "object", "properties": {"age": {"type": "integer"}}}', '{"age": "thirty"}'), 'pg_jsonschema: invalid document');

CREATE EXTENSION postgres_protobuf;

SELECT assert_true(to_regproc('protobuf_query') IS NOT NULL, 'postgres_protobuf: protobuf_query()');
SELECT assert_true(to_regproc('protobuf_to_json_text') IS NOT NULL, 'postgres_protobuf: protobuf_to_json_text()');

CREATE EXTENSION pg_hashids;

SELECT assert_true((id_decode(id_encode(42, 'salt'), 'salt'))[1] = 42, 'pg_hashids: encode/decode round trip');
SELECT assert_true(id_encode(42, 'salt') <> id_encode(42, 'pepper'), 'pg_hashids: salt changes the hash');

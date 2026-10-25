CREATE EXTENSION pg_uuidv7;

SELECT assert_true(uuid_v7_to_timestamptz(uuid_generate_v7()) > now() - interval '1 minute', 'pg_uuidv7: timestamp in the UUID');
SELECT assert_true(uuid_generate_v7() > uuid_timestamptz_to_v7('2020-01-01'), 'pg_uuidv7: time ordered');

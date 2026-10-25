-- Runs in pg_net.database_name, where its background worker looks for it.
CREATE EXTENSION IF NOT EXISTS pg_net;

-- No network calls in tests: check the API.
SELECT assert_true(to_regproc('net.http_get') IS NOT NULL, 'pg_net: net.http_get()');
SELECT assert_true(to_regclass('net.http_request_queue') IS NOT NULL, 'pg_net: request queue');

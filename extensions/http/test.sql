CREATE EXTENSION http;

-- No network calls in tests: check the request and response types.
SELECT assert_true((http_header('Accept', 'application/json')).field = 'Accept', 'http: http_header()');
SELECT assert_true(to_regprocedure('http_get(character varying)') IS NOT NULL, 'http: http_get()');

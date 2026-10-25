CREATE EXTENSION pg_csv;

SELECT assert_true((SELECT csv_agg(t) FROM (VALUES (1, 'a'), (2, 'b')) t(id, name)) LIKE '%1,a%2,b%', 'pg_csv: csv_agg()');

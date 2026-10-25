CREATE EXTENSION pg_background;

SELECT assert_true(
  (WITH h AS (SELECT pg_background_launch('SELECT 42') AS handle)
   SELECT v FROM h, pg_background_result((h.handle).pid, (h.handle).cookie) AS r(v int)) = 42,
  'pg_background: result of a background query');

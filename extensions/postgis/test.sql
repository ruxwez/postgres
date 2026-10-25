CREATE EXTENSION postgis;

DO $$
BEGIN
  IF ST_Distance('POINT(0 0)'::geometry, 'POINT(3 4)'::geometry) <> 5 THEN
    RAISE EXCEPTION 'postgis: unexpected distance';
  END IF;
END $$;

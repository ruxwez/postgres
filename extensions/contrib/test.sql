CREATE EXTENSION pg_stat_statements;
CREATE EXTENSION pg_trgm;

DO $$
BEGIN
  IF similarity('postgres', 'postgis') <= 0 THEN
    RAISE EXCEPTION 'contrib: pg_trgm similarity returned 0';
  END IF;
END $$;

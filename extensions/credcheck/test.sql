-- credcheck is a hook loaded with shared_preload_libraries, not an extension.
SET credcheck.password_min_length = 12;

DO $$
DECLARE
  rejected boolean := false;
BEGIN
  BEGIN
    CREATE ROLE credcheck_weak LOGIN PASSWORD 'short';
  EXCEPTION WHEN OTHERS THEN
    rejected := true;
  END;
  PERFORM assert_true(rejected, 'credcheck: a short password should be rejected');
END $$;

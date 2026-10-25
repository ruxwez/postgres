CREATE EXTENSION plpgsql_check;

CREATE FUNCTION good() RETURNS int LANGUAGE plpgsql AS $$ BEGIN RETURN 42; END $$;
CREATE FUNCTION bad() RETURNS int LANGUAGE plpgsql AS $$ BEGIN RETURN missing_column; END $$;

SELECT assert_true((SELECT count(*) FROM plpgsql_check_function('good()')) = 0, 'plpgsql_check: valid function');
SELECT assert_true((SELECT count(*) FROM plpgsql_check_function('bad()')) > 0, 'plpgsql_check: error found');

CREATE EXTENSION pg_rrule;

SELECT assert_true(array_length(get_occurrences('FREQ=DAILY;COUNT=3'::rrule, '2020-01-01 00:00:00'::timestamp), 1) = 3, 'pg_rrule: get_occurrences()');

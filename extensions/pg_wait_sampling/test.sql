CREATE EXTENSION pg_wait_sampling;

SELECT assert_true((SELECT count(*) FROM pg_wait_sampling_profile) >= 0, 'pg_wait_sampling: profile readable');

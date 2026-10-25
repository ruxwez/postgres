CREATE EXTENSION semver;

SELECT assert_true('2.0.0'::semver > '1.10.0'::semver, 'semver: comparison');
SELECT assert_true('1.10.0'::semver > '1.9.0'::semver, 'semver: numeric, not text, ordering');

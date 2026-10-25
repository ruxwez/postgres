CREATE EXTENSION pg_pwhash;

-- Like pgcrypto's crypt(): the hash itself is the salt to verify against.
SELECT pwhash_crypt('secret', pwhash_gen_salt('scrypt')) AS hash \gset
SELECT assert_true(:'hash' LIKE '$scrypt$%', 'pg_pwhash: scrypt hash');
SELECT assert_true(pwhash_crypt('secret', :'hash') = :'hash', 'pg_pwhash: right password verifies');
SELECT assert_true(pwhash_crypt('wrong', :'hash') <> :'hash', 'pg_pwhash: wrong password rejected');

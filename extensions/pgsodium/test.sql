CREATE EXTENSION pgsodium;

SELECT assert_true(length(pgsodium.randombytes_buf(32)) = 32, 'pgsodium: randombytes_buf()');
SELECT assert_true(
  (SELECT pgsodium.crypto_secretbox_open(pgsodium.crypto_secretbox('hello', nonce, key), nonce, key) = 'hello'::bytea
   FROM (SELECT pgsodium.crypto_secretbox_keygen() AS key, pgsodium.crypto_secretbox_noncegen() AS nonce) k),
  'pgsodium: secretbox round trip');

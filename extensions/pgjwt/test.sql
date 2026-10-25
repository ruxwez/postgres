CREATE EXTENSION pgjwt CASCADE;

SELECT assert_true((SELECT valid FROM verify(sign('{"sub": "alice"}', 'secret'), 'secret')), 'pgjwt: sign/verify');
SELECT assert_true(NOT (SELECT valid FROM verify(sign('{"sub": "alice"}', 'secret'), 'wrong')), 'pgjwt: wrong secret rejected');

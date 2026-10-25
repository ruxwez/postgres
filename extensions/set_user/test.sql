CREATE EXTENSION set_user;
CREATE ROLE set_user_alice NOSUPERUSER;

SELECT set_user('set_user_alice');
SELECT assert_true(current_user = 'set_user_alice', 'set_user: switched role');
SELECT reset_user();
SELECT assert_true(current_user = 'postgres', 'set_user: reset_user()');

DROP ROLE set_user_alice;

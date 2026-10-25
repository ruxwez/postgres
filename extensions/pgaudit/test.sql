CREATE EXTENSION pgaudit;

SET pgaudit.log = 'ddl';
SELECT assert_true(current_setting('pgaudit.log') = 'ddl', 'pgaudit: settings registered');

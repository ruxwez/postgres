CREATE EXTENSION temporal_tables;

CREATE TABLE employees (id int PRIMARY KEY, title text, sys_period tstzrange NOT NULL DEFAULT tstzrange(now(), NULL));
CREATE TABLE employees_history (LIKE employees);
CREATE TRIGGER versioning BEFORE INSERT OR UPDATE OR DELETE ON employees
  FOR EACH ROW EXECUTE PROCEDURE versioning('sys_period', 'employees_history', true);

INSERT INTO employees (id, title) VALUES (1, 'engineer');
UPDATE employees SET title = 'manager' WHERE id = 1;
SELECT assert_true((SELECT title FROM employees_history) = 'engineer', 'temporal_tables: old version kept');

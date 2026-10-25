CREATE EXTENSION pljs;

CREATE FUNCTION js_add(a int, b int) RETURNS int LANGUAGE pljs AS 'return a + b;';
SELECT assert_true(js_add(2, 3) = 5, 'pljs: JavaScript function');

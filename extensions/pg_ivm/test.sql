CREATE EXTENSION pg_ivm;

CREATE TABLE orders (product text, amount int);
INSERT INTO orders VALUES ('A', 100), ('B', 200);
SELECT pgivm.create_immv('order_totals', 'SELECT product, sum(amount) AS total FROM orders GROUP BY product');
INSERT INTO orders VALUES ('A', 50);

SELECT assert_true((SELECT total FROM order_totals WHERE product = 'A') = 150, 'pg_ivm: view updated incrementally');

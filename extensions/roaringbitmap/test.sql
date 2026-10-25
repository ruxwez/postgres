CREATE EXTENSION roaringbitmap;

SELECT assert_true(rb_cardinality(rb_and(rb_build(ARRAY[1, 2, 3]), rb_build(ARRAY[2, 3, 4]))) = 2, 'roaringbitmap: intersection');
SELECT assert_true(rb_cardinality(rb_or(rb_build(ARRAY[1, 2, 3]), rb_build(ARRAY[3, 4, 5]))) = 5, 'roaringbitmap: union');

CREATE EXTENSION pgtt;
LOAD 'pgtt';

CREATE /*GLOBAL*/ TEMPORARY TABLE session_cart (item text) ON COMMIT PRESERVE ROWS;
INSERT INTO session_cart VALUES ('book');
SELECT assert_true((SELECT count(*) FROM session_cart) = 1, 'pgtt: global temporary table');

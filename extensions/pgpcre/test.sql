CREATE EXTENSION pgpcre;

SELECT assert_true('foobar' ~ 'f.ob'::pcre, 'pgpcre: match');
SELECT assert_true(pcre_match('([0-9]+)', 'abc123') = '123', 'pgpcre: pcre_match()');

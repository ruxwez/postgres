CREATE EXTENSION icu_ext;

SELECT assert_true(icu_char_name('A') = 'LATIN CAPITAL LETTER A', 'icu_ext: icu_char_name()');
SELECT assert_true(icu_transform('Æ', 'Latin-ASCII') = 'AE', 'icu_ext: icu_transform()');

CREATE EXTENSION prefix;

CREATE TABLE phone_prefixes (prefix prefix_range, country text);
INSERT INTO phone_prefixes VALUES ('33', 'FR'), ('34', 'ES'), ('349', 'ES mobile');
CREATE INDEX ON phone_prefixes USING gist (prefix);

SELECT assert_true(
  (SELECT country FROM phone_prefixes WHERE prefix @> '34912345678' ORDER BY length(prefix) DESC LIMIT 1) = 'ES mobile',
  'prefix: longest prefix match');

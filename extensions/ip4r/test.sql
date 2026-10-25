CREATE EXTENSION ip4r;

SELECT assert_true('10.0.0.0/8'::ip4r >>= '10.1.2.3'::ip4, 'ip4r: range contains address');

CREATE TABLE networks (network ip4r);
INSERT INTO networks VALUES ('10.0.0.0/24'), ('172.16.0.0/16'), ('192.168.1.0/24');
CREATE INDEX ON networks USING gist (network);
SELECT assert_true((SELECT count(*) FROM networks WHERE network >>= '172.16.5.10') = 1, 'ip4r: indexed lookup');

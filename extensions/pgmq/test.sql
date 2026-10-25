CREATE EXTENSION pgmq;

SELECT pgmq.create('test_queue');
SELECT pgmq.send(queue_name => 'test_queue', msg => '{"hello": "world"}');

DO $$
DECLARE
  msg jsonb;
BEGIN
  SELECT message INTO msg FROM pgmq.read(queue_name => 'test_queue', vt => 30, qty => 1);
  IF msg->>'hello' IS DISTINCT FROM 'world' THEN
    RAISE EXCEPTION 'pgmq: round-trip failed, got %', msg;
  END IF;
END $$;

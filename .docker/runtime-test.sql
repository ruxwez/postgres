CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgmq;
CREATE EXTENSION IF NOT EXISTS postgis;

SELECT extname FROM pg_extension WHERE extname IN ('vector','pgmq','postgis');
SELECT name FROM pg_available_extensions WHERE name IN ('pg_stat_statements');

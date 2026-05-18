#!/usr/bin/env bash

set -euo pipefail

POSTGRES_VERSION="${POSTGRES_VERSION:-18}"
IMAGE="${IMAGE:-postgres-extensor-runtime-test}"
CONTAINER_NAME="${CONTAINER_NAME:-postgres-extensor-runtime-test-$$}"

cleanup() {
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
}

trap cleanup EXIT

if [ "${SKIP_BUILD:-false}" != "true" ]; then
  docker build -f .docker/Dockerfile -t "${IMAGE}" --build-arg POSTGRES_VERSION="${POSTGRES_VERSION}" .
fi

docker run -d --rm --name "${CONTAINER_NAME}" \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=postgres \
  "${IMAGE}" >/dev/null

for _ in $(seq 1 30); do
  if docker exec "${CONTAINER_NAME}" pg_isready -U postgres >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! docker exec "${CONTAINER_NAME}" pg_isready -U postgres >/dev/null 2>&1; then
  echo "PostgreSQL did not become ready in time" >&2
  exit 1
fi

docker exec -i "${CONTAINER_NAME}" psql -v ON_ERROR_STOP=1 -U postgres -d postgres <<'SQL'
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgmq;
CREATE EXTENSION IF NOT EXISTS postgis;

SELECT extname FROM pg_extension WHERE extname IN ('vector','pgmq','postgis');
SELECT name FROM pg_available_extensions WHERE name IN ('pg_stat_statements');
SQL

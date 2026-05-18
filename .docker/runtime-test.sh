#!/usr/bin/env bash

set -euo pipefail

POSTGRES_VERSION="${POSTGRES_VERSION:-18}"
IMAGE="${IMAGE:-postgres-extensor-runtime-test}"
CONTAINER_NAME="${CONTAINER_NAME:-postgres-extensor-runtime-test-$$}"

trap 'docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true' EXIT

if [ "${SKIP_BUILD:-false}" != "true" ]; then
  docker build -f .docker/Dockerfile -t "${IMAGE}" --build-arg POSTGRES_VERSION="${POSTGRES_VERSION}" .
fi

docker run -d --rm --name "${CONTAINER_NAME}" -e POSTGRES_PASSWORD=postgres "${IMAGE}" >/dev/null

echo "Waiting for PostgreSQL to start..."
until docker exec "${CONTAINER_NAME}" pg_isready -U postgres >/dev/null 2>&1; do
  sleep 1
done

echo "Running SQL tests..."
docker exec -i "${CONTAINER_NAME}" psql -v ON_ERROR_STOP=1 -U postgres < .docker/runtime-test.sql
echo "Tests passed successfully!"

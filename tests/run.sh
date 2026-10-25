#!/usr/bin/env bash
#
# Usage: tests/run.sh IMAGE
#
# Starts IMAGE and runs every extensions/*/test.sql against it, each one in a
# fresh database. Fails if any test fails.
#
# If SUMMARY_FILE is set, writes there the PostgreSQL version and the version
# of every extension the tests created, one "name version" pair per line.

set -euo pipefail

IMAGE="${1:?usage: $0 IMAGE}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTAINER="postgres-extensor-test-$$"

trap 'docker rm -f "$CONTAINER" >/dev/null 2>&1 || true' EXIT

docker run -d --name "$CONTAINER" -e POSTGRES_PASSWORD=postgres "$IMAGE" >/dev/null

# Connect over TCP: during first-boot initialisation the entrypoint runs a
# temporary server on the unix socket only, so this waits for the real one.
pg() {
  docker exec -i -e PGPASSWORD=postgres "$CONTAINER" psql -h 127.0.0.1 -U postgres -X -q -v ON_ERROR_STOP=1 "$@"
}

echo "Waiting for PostgreSQL..."
for _ in $(seq 60); do
  docker exec "$CONTAINER" pg_isready -h 127.0.0.1 -U postgres -q && break
  sleep 1
done
if ! docker exec "$CONTAINER" pg_isready -h 127.0.0.1 -U postgres -q; then
  docker logs "$CONTAINER"
  echo "PostgreSQL did not start" >&2
  exit 1
fi
pg -At -c 'SELECT version()'

summary="postgresql $(pg -At -c "SELECT split_part(current_setting('server_version'), ' ', 1)")"$'\n'

failed=()
for sql in "$ROOT"/extensions/*/test.sql; do
  name="$(basename "$(dirname "$sql")")"
  db="test_${name//-/_}"
  pg -c "CREATE DATABASE $db" >/dev/null
  if output="$(pg -d "$db" <"$sql" 2>&1)"; then
    versions="$(pg -d "$db" -At -F ' ' -c "SELECT extname, extversion FROM pg_extension WHERE extname <> 'plpgsql' ORDER BY extname")"
    summary+="$versions"$'\n'
    echo "PASS  $name  (${versions//$'\n'/, })"
  else
    echo "FAIL  $name"
    echo "$output" | sed 's/^/      /'
    failed+=("$name")
  fi
done

if [ -n "${SUMMARY_FILE:-}" ]; then
  printf '%s' "$summary" >"$SUMMARY_FILE"
fi

if [ "${#failed[@]}" -gt 0 ]; then
  echo "Failed: ${failed[*]}" >&2
  exit 1
fi
echo "All tests passed."

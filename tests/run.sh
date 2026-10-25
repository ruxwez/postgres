#!/usr/bin/env bash
#
# Usage: tests/run.sh IMAGE
#
# Starts IMAGE and runs every extensions/*/test.sql against it, each one in a
# fresh database. Fails if any test fails.
#
# Each extensions/<name>/ directory can also have:
#   server.conf  settings the extension needs (postgresql.conf syntax), e.g.
#                shared_preload_libraries. They're applied to the test server.
#   pg-versions  the PostgreSQL majors the extension supports, e.g. "17 18".
#                On other majors the test is reported as SKIP.
#   database     run the test in this existing database instead of a fresh
#                one (e.g. "postgres", for extensions tied to pg_cron's).
#   isolated     run the test on a server of its own, with only its own
#                server.conf. The file says why (e.g. it conflicts with
#                another extension).
#
# Tests can call assert_true(condition, message), which raises an error with
# the message when the condition isn't true.
#
# If SUMMARY_FILE is set, writes there the PostgreSQL version and the version
# of every extension the tests created, one "name version" pair per line.

set -euo pipefail

IMAGE="${1:?usage: $0 IMAGE}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTAINER="postgres-extensor-test-$$"

trap 'docker rm -f "$CONTAINER" >/dev/null 2>&1 || true' EXIT

major="$(docker image inspect "$IMAGE" --format '{{range .Config.Env}}{{println .}}{{end}}' | sed -n 's/^PG_MAJOR=//p')"

supported() {
  local versions="$1/pg-versions"
  [ ! -e "$versions" ] || grep -qw "$major" "$versions"
}

# Starts the test server with the server.conf of the given extension
# directories. shared_preload_libraries entries are merged into one list; any
# other setting is passed as is.
start_server() {
  local preload=() settings=() dir key value lib libs
  for dir in "$@"; do
    [ -e "$dir/server.conf" ] || continue
    while IFS='=' read -r key value; do
      key="$(echo "$key" | xargs)"
      value="$(echo "$value" | xargs)"
      value="${value#\'}"
      value="${value%\'}"
      case "$key" in
        '' | \#*) ;;
        shared_preload_libraries)
          IFS=',' read -ra libs <<<"$value"
          for lib in "${libs[@]}"; do
            lib="$(echo "$lib" | xargs)"
            [[ " ${preload[*]} " == *" $lib "* ]] || preload+=("$lib")
          done ;;
        *) settings+=(-c "$key=$value") ;;
      esac
    done <"$dir/server.conf"
  done
  if [ "${#preload[@]}" -gt 0 ]; then
    settings+=(-c "shared_preload_libraries=$(IFS=,; echo "${preload[*]}")")
  fi

  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  docker run -d --name "$CONTAINER" -e POSTGRES_PASSWORD=postgres "$IMAGE" postgres "${settings[@]}" >/dev/null

  # Connect over TCP: during first-boot initialisation the entrypoint runs a
  # temporary server on the unix socket only, so this waits for the real one.
  for _ in $(seq 60); do
    docker exec "$CONTAINER" pg_isready -h 127.0.0.1 -U postgres -q && return 0
    sleep 1
  done
  docker logs "$CONTAINER"
  echo "PostgreSQL did not start" >&2
  exit 1
}

pg() {
  docker exec -i -e PGPASSWORD=postgres "$CONTAINER" psql -h 127.0.0.1 -U postgres -X -q -v ON_ERROR_STOP=1 "$@"
}

assert_function="
CREATE OR REPLACE FUNCTION public.assert_true(condition boolean, message text) RETURNS void
LANGUAGE plpgsql AS \$\$
BEGIN
  IF condition IS NOT TRUE THEN
    RAISE EXCEPTION 'assertion failed: %', message;
  END IF;
END \$\$;"

declare -A versions=()
passed=0
failed=()

run_test() {
  local dir="$1" name db output created ext version
  name="$(basename "$dir")"
  if [ -e "$dir/database" ]; then
    db="$(xargs <"$dir/database")"
  else
    db="test_${name//-/_}"
  fi
  if output="$( { [ -e "$dir/database" ] || pg -c "CREATE DATABASE $db"; } 2>&1 >/dev/null &&
                (echo "$assert_function"; cat "$dir/test.sql") | pg -d "$db" 2>&1)"; then
    created="$(pg -d "$db" -At -F ' ' -c "SELECT extname, extversion FROM pg_extension WHERE extname <> 'plpgsql' ORDER BY extname")"
    while read -r ext version; do
      [ -n "$ext" ] && versions[$ext]="$version"
    done <<<"$created"
    echo "PASS  $name  (${created//$'\n'/, })"
    passed=$((passed + 1))
  else
    echo "FAIL  $name"
    echo "$output" | sed 's/^/      /'
    failed+=("$name")
    wait_for_recovery
  fi
}

# If a test crashed the server, PostgreSQL restarts and recovers on its own:
# wait for it so the remaining tests still run.
wait_for_recovery() {
  for _ in $(seq 60); do
    pg -At -c 'SELECT 1' >/dev/null 2>&1 && return 0
    sleep 1
  done
  docker logs --tail 50 "$CONTAINER"
  echo "PostgreSQL did not recover" >&2
  exit 1
}

shared=()
isolated=()
skipped=()
for dir in "$ROOT"/extensions/*/; do
  dir="${dir%/}"
  [ -e "$dir/test.sql" ] || continue
  if ! supported "$dir"; then
    echo "SKIP  $(basename "$dir")  (supports PostgreSQL $(xargs <"$dir/pg-versions"))"
    skipped+=("$(basename "$dir")")
  elif [ -e "$dir/isolated" ]; then
    isolated+=("$dir")
  else
    shared+=("$dir")
  fi
done

echo "Starting PostgreSQL..."
start_server "${shared[@]}"
pg -At -c 'SELECT version()'
pg_version="$(pg -At -c "SELECT split_part(current_setting('server_version'), ' ', 1)")"
for dir in "${shared[@]}"; do
  run_test "$dir"
done

for dir in "${isolated[@]}"; do
  echo "Starting PostgreSQL for $(basename "$dir") alone (see extensions/$(basename "$dir")/isolated)..."
  start_server "$dir"
  run_test "$dir"
done

if [ -n "${SUMMARY_FILE:-}" ]; then
  {
    echo "postgresql $pg_version"
    for ext in "${!versions[@]}"; do
      echo "$ext ${versions[$ext]}"
    done | sort
  } >"$SUMMARY_FILE"
fi

echo "Passed: $passed, skipped: ${#skipped[@]}, failed: ${#failed[@]}"
if [ "${#failed[@]}" -gt 0 ]; then
  echo "Failed: ${failed[*]}" >&2
  exit 1
fi
echo "All tests passed."

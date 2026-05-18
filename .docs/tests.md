# Tests

> [Leer en español](./tests.es.md)

This project uses **integration tests** rather than Go unit tests (`_test.go`). The binary runs inside a Docker image at build time, interacting directly with the OS (apt, git, make, pg_config, etc.). There is no isolatable business logic that would benefit from traditional unit tests.

---

## `make test` — Build test

```sh
make test
```

Builds the Docker image using `.docker/Dockerfile.test`. This Dockerfile runs `./main` inside a `postgres:13` container and verifies the entire extension installation pipeline compiles and executes without errors. The image is removed afterwards.

- **Purpose:** Fast validation that the code compiles and playgrounds don't crash.
- **Limitation:** Uses hardcoded PostgreSQL 13, regardless of `PG_VERSION`.

---

## `make runtime-test` — Runtime test

```sh
make runtime-test           # PG_VERSION=18 by default
PG_VERSION=17 make runtime-test
```

Runs the `.docker/runtime-test.sh` script, which:

1. Builds the production Docker image (`.docker/Dockerfile`).
2. Starts a container with `POSTGRES_PASSWORD=postgres`.
3. Waits for PostgreSQL readiness (`pg_isready`).
4. Executes `.docker/runtime-test.sql` against the database via `psql`.

The SQL script verifies:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgmq;
CREATE EXTENSION IF NOT EXISTS postgis;

-- Confirms extensions are installed
SELECT * FROM pg_extension WHERE extname IN ('vector', 'pgmq', 'postgis');

-- Confirms contrib is available
SELECT * FROM pg_available_extensions WHERE name = 'pg_stat_statements';
```

- **Purpose:** Real validation that all extensions install correctly and work inside PostgreSQL.
- **Versions:** Runs against the PostgreSQL version specified by `PG_VERSION`.

---

## CI — GitHub Actions

The `pr-test.yml` workflow runs the runtime test matrix for all supported versions (`14`, `15`, `16`, `17`, `18`, `latest`) on `linux/amd64` for every Pull Request. This ensures changes work across the entire supported version range.

---

## How to extend the tests

### Add verification for a new extension

Edit `.docker/runtime-test.sql`:

```sql
CREATE EXTENSION IF NOT EXISTS my_extension;
SELECT * FROM pg_extension WHERE extname = 'my_extension';
```

### Add a new step in runtime-test.sh

If you need additional logic before or after the SQL tests (e.g., copy files, check permissions), edit `.docker/runtime-test.sh`.

### Unit tests (future)

If reusable logic is extracted in the future (e.g., version parsing or handler matching), add `_test.go` files in the corresponding packages and run them with:

```sh
go test ./...
```

Currently none exist because the project's logic is tightly coupled to the Docker environment.

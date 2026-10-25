# Tests

> [Leer en español](./tests.es.md)

The tests check the **final image**: they start a container and use each extension inside a real PostgreSQL instance.

## Running them

```sh
make test                   # build PG 18 for your platform and test it
make test PG_VERSION=14

./tests/run.sh <image>      # test an image that's already built
```

## What `tests/run.sh` does

1. Starts the image with `POSTGRES_PASSWORD=postgres` and the settings from every `extensions/*/server.conf` (`shared_preload_libraries` values are merged).
2. Waits until PostgreSQL accepts TCP connections. The entrypoint's temporary init server only listens on the unix socket, so this check doesn't stop too early.
3. For every `extensions/*/test.sql`, it creates a fresh database, runs the file with `ON_ERROR_STOP=1`, and prints `PASS` (with the extension versions it created) or `FAIL` (with the error). Extensions that don't support this PostgreSQL major are reported as `SKIP`.
4. Runs the tests marked `isolated` on a server of their own.
5. Exits non-zero if any test failed, after running all of them.

```
PASS  age  (age 1.8.0)
PASS  anon  (anon 3.2.3)
…
SKIP  pg_textsearch  (supports PostgreSQL 17 18)
…
Passed: 81, skipped: 1, failed: 0
All tests passed.
```

To test a new extension, add its `test.sql` (see [Extensions](./extensions.md#writing-the-test), which also explains `server.conf`, `pg-versions`, `database` and `isolated`). You don't need to register it anywhere.

## CI

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs on every PR, on `main`, on `vX.Y.Z` tags, weekly and on manual dispatch:

1. **Prepare:** reads the versions from `docker-bake.hcl`. For a release tag, it also checks the release is valid and not published yet (see [Releases](./releases.md)).
2. **Build and test** every version on `amd64` and `arm64`, using native runners (no emulation).
3. **All builds passed:** a single status check, for branch protection.
4. **Publish** (not on PRs): pushes the exact images that were tested and creates the tags as multi-arch manifests. Nothing is published unless every version passes on both architectures.
5. **GitHub release** (release tags only): creates the release with the versions reported by the tests.

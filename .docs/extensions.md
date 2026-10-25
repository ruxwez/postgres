# Extensions

> [Leer en español](./extensions.es.md)

Every extension has two parts:

1. **How it's installed**: a line in [`extensions/pgdg.txt`](../extensions/pgdg.txt), or a few lines in the [`Dockerfile`](../Dockerfile).
2. **How it's tested**: `extensions/<name>/test.sql`.

There is no other code to touch. The full list of what's included is in [Included extensions](./included-extensions.md).

## Adding an extension

Pick the first option that works, in this order.

### Option A: it's packaged in PGDG (preferred)

Look for `postgresql-<major>-<package>` on [apt.postgresql.org](https://apt.postgresql.org/pub/repos/apt/pool/main/), and list the versions it has:

```sh
docker run --rm postgres:18 bash -c 'apt-get update -qq && apt-cache madison postgresql-18-<package>'
```

If the same upstream version exists for every supported major, add one line to `extensions/pgdg.txt`:

```
my-package              1.2.3
```

If the version differs per major, or the package doesn't exist for some of them, add one line per major instead:

```
my-package/17           2.0.1
my-package/18           2.1.0
```

The version is the upstream one, without the Debian revision: `1.2.3` matches `1.2.3-1.pgdg13+1`. Renovate updates these lines and groups them into one weekly PR.

### Option B: the authors publish prebuilt packages

If the authors attach a `.deb` (or a `.zip` with one) per PostgreSQL major and architecture to their releases, add it to the `prebuilt` stage. `fetch-deb` downloads it and keeps only its PostgreSQL files:

```dockerfile
# at the top, with the other versions
# renovate: datasource=github-releases depName=owner/my-extension
ARG MY_EXTENSION_VERSION=1.2.3

# in the prebuilt stage
ARG MY_EXTENSION_VERSION
RUN fetch-deb "https://github.com/owner/my-extension/releases/download/v${MY_EXTENSION_VERSION}/my-extension-pg${PG_MAJOR}-${TARGETARCH}.deb"
```

### Option C: build it from source

Add a line to the `source` stage. `pgxs-build` fetches a tag (or a commit) and runs `make install` into `/out`:

```dockerfile
# at the top, with the other versions
# renovate: datasource=github-tags depName=owner/my-extension
ARG MY_EXTENSION_VERSION=1.2.3

# in the source stage
ARG MY_EXTENSION_VERSION
RUN pgxs-build https://github.com/owner/my-extension.git "v${MY_EXTENSION_VERSION}"
```

Optional arguments: a subdirectory, then extra `make` arguments (`pgxs-build URL TAG subdir USE_PGXS=1`). Prefix with `MIN_PG_MAJOR=16` to skip older majors that the extension doesn't support. If the build needs `-dev` packages, add them to the `apt-get install` of the `source` stage; they don't reach the final image. Runtime libraries go in the final stage's `apt-get install`.

The `# renovate:` comment right above the `ARG` lets Renovate open a PR whenever a new version is released. Keep the same format.

## Writing the test

Create `extensions/<name>/test.sql`. It should **use** the extension, not only create it, and fail if the result is wrong. `assert_true(condition, message)` is available in every test database:

```sql
CREATE EXTENSION my_extension;

SELECT assert_true(my_function(1) = 2, 'my_extension: my_function()');
```

`tests/run.sh` picks it up automatically. Each test runs in a fresh database, all of them on one server. These optional files in the same directory change that:

| File | Content | Effect |
|---|---|---|
| `server.conf` | `postgresql.conf` lines, e.g. `shared_preload_libraries = 'my_extension'` | Applied to the test server. `shared_preload_libraries` values from every extension are merged. |
| `pg-versions` | Supported majors, e.g. `17 18` | On other majors the test is reported as `SKIP` instead of failing. |
| `database` | A database name, e.g. `postgres` | The test runs there instead of in a fresh database (pg_cron and the extensions that depend on it need this). |
| `isolated` | Why the extension can't share a server | The test runs on a server of its own, with only its own `server.conf`. |

Finally, add the extension to [Included extensions](./included-extensions.md) and to the category table in the README.

## Upgrading an extension

Change its version in `extensions/pgdg.txt` or in its `ARG` at the top of the Dockerfile. Renovate opens these PRs for you.

Once merged, the change only reaches `18` and `latest`. To ship it to `18-v1`, cut a release (see [Releases](./releases.md) to pick the version bump).

## Adding or dropping a PostgreSQL version

Edit the `major` list in [`docker-bake.hcl`](../docker-bake.hcl). To move `:latest` to a new major, change `LATEST` too. CI builds and tests every version in that list. If an extension isn't available for a new major, either give it a `pg-versions` file (and the matching per-major lines or `MIN_PG_MAJOR`), or wait until it is.

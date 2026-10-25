# PostgreSQL Extensor

[![CI](https://github.com/ruxwez/postgres/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/ruxwez/postgres/actions/workflows/ci.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/ruxwez/postgres)](https://hub.docker.com/r/ruxwez/postgres)
[![Release](https://img.shields.io/github/v/release/ruxwez/postgres)](https://github.com/ruxwez/postgres/releases)
[![License: MIT](https://img.shields.io/github/license/ruxwez/postgres)](./LICENSE)

> [Leer en español](./README.es.md)

**The official PostgreSQL image with 80+ extensions preinstalled**: pgvector, PostGIS, pgmq, TimescaleDB, pg_cron, pg_duckdb, Apache AGE, pg_graphql and [many more](./.docs/included-extensions.md). Vector search, geospatial queries, queues, time series and analytics in a single Postgres: no extra services, and no custom image to maintain.

- **Drop-in replacement** for `postgres`. Same entrypoint, same environment variables, same defaults; nothing is enabled until you run `CREATE EXTENSION`.
- **PostgreSQL 14 to 18**, on `linux/amd64` and `linux/arm64`. Every extension has a functional test, run on both architectures before every publish.
- **Immutable versioned tags** (`18-v1.0.0`), so an update never reaches you unless you ask for it.
- **Rebuilt weekly** with the base image's security fixes.

## Quick start

```sh
docker run -d --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 ruxwez/postgres:18-v1
```

Or with Docker Compose:

```yaml
services:
  db:
    image: ruxwez/postgres:18-v1
    environment:
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql   # PostgreSQL 17 and older: /var/lib/postgresql/data

volumes:
  pgdata:
```

Enable the extensions you need in each database, and use them together:

```sql
CREATE EXTENSION vector;
CREATE EXTENSION postgis;
CREATE EXTENSION pgmq;

CREATE TABLE places (
  id        bigserial PRIMARY KEY,
  name      text,
  location  geography(Point),
  embedding vector(3)
);

INSERT INTO places (name, location, embedding) VALUES
  ('Café Central', 'POINT(-3.7038 40.4168)', '[0.9, 0.1, 0.0]'),
  ('Tapas Bar',    'POINT(-3.7010 40.4180)', '[0.2, 0.8, 0.1]'),
  ('Café del Mar', 'POINT( 1.3090 38.9800)', '[0.9, 0.2, 0.0]');

-- The place most similar to "coffee" within 5 km of Puerta del Sol → Café Central
SELECT name
FROM places
WHERE ST_DWithin(location, 'POINT(-3.7037 40.4169)', 5000)
ORDER BY embedding <=> '[1, 0, 0]'
LIMIT 1;

-- Queue a background job to recompute embeddings
SELECT pgmq.create('embeddings');
SELECT pgmq.send(queue_name => 'embeddings', msg => '{"place_id": 1}');
SELECT msg_id, message FROM pgmq.read(queue_name => 'embeddings', vt => 30, qty => 1);
```

## Why this image

If you only need one extension, its own image is a great choice. This one is for when you need several:

| | `postgres` | `pgvector/pgvector` | `postgis/postgis` | `pglayers-full` | **`ruxwez/postgres`** |
|---|:-:|:-:|:-:|:-:|:-:|
| Extensions beyond contrib | — | 1 | 1 | 80+ | 80+ |
| PostgreSQL 14–16 | ✅ | ✅ | ✅ | — | ✅ |
| `linux/arm64` (Apple Silicon, Graviton, Raspberry Pi) | ✅ | ✅ | — | ✅ | ✅ |
| Same defaults as the official image | ✅ | ✅ | ✅ | — (preloads libraries) | ✅ |

<sub>Checked in October 2026 on the PostgreSQL 14 and 18 tags of each image. [pglayers](https://github.com/pglayers/pglayers) also publishes each extension as a separate layer, which suits you if you want to assemble your own image.</sub>

## Tags

Pick a tag depending on how much change you're willing to accept:

| Tag | Example | Changes? |
|-----|---------|----------|
| `<pg>-v<X.Y.Z>` | `18-v1.0.0` | **Never.** Published once per release, never overwritten. |
| `<pg>-v<X>` | `18-v1` | With every `v1.x.y` release: compatible updates only. **Recommended.** |
| `<pg>` | `18` | On every build, including weekly rebuilds and breaking changes. |
| `latest` | | Same as the newest `<pg>` (currently `18`). |

The `vX.Y.Z` version belongs to this project, not to PostgreSQL: it changes when an extension changes. Each [release](https://github.com/ruxwez/postgres/releases) lists the exact PostgreSQL and extension versions of every image. See [Releases](./.docs/releases.md) for what each kind of bump means.

Each image also lists what it contains:

```sh
docker run --rm ruxwez/postgres:18-v1 cat /usr/share/postgres-extensor/extensions.txt
```

For byte-for-byte reproducibility, pin a digest: `ruxwez/postgres@sha256:…`.

### Included extensions

| Category | Extensions |
|---|---|
| AI and vectors | pgvector, pgvectorscale |
| Geospatial | PostGIS, pgRouting, H3, pgSphere |
| Search and text | pg_textsearch (BM25), RUM, pg_bigm, pg_similarity, pgpcre, re2, icu_ext |
| Time series and analytics | TimescaleDB, pg_duckdb, pg_ivm, pg_incremental, hll, tdigest, roaringbitmap, … |
| Queues and jobs | pgmq, pg_cron, pg_background, pg_partman |
| JSON, documents and APIs | DocumentDB, pg_graphql, pg_jsonschema, jsquery, http, pg_net, pgjwt, … |
| Data types | Apache AGE (graphs), pg_uuidv7, pg_hashids, ip4r, semver, periods, temporal_tables, … |
| Replication and CDC | pglogical, wal2json, pg_failover_slots |
| Monitoring and performance | pg_stat_monitor, pg_stat_kcache, pg_qualstats, hypopg, pg_hint_plan, pg_repack, pg_squeeze, … |
| Security | pgaudit, PostgreSQL Anonymizer, pgsodium, credcheck, set_user, … |
| Foreign data | Supabase Wrappers, pg_clickhouse, tds_fdw |
| Development and compatibility | pgTAP, plpgsql_check, plprofiler, PLJS, orafce, pgtt, db2fce |

Plus all of [contrib](https://www.postgresql.org/docs/current/contrib.html). See the [full list](./.docs/included-extensions.md) for links, which ones need `shared_preload_libraries`, and known caveats.

## Use it in tests and CI

**GitHub Actions** service container:

```yaml
services:
  postgres:
    image: ruxwez/postgres:18-v1
    env:
      POSTGRES_PASSWORD: postgres
    ports:
      - 5432:5432
    options: >-
      --health-cmd pg_isready
      --health-interval 5s
      --health-timeout 5s
      --health-retries 10
```

**Testcontainers (Java).** Declare it as a substitute for `postgres`, so the PostgreSQL module accepts it:

```java
var image = DockerImageName.parse("ruxwez/postgres:18-v1").asCompatibleSubstituteFor("postgres");
try (var postgres = new PostgreSQLContainer<>(image)) {
    postgres.start();
}
```

**Testcontainers (Python):**

```python
from testcontainers.postgres import PostgresContainer

with PostgresContainer("ruxwez/postgres:18-v1") as postgres:
    url = postgres.get_connection_url()
```

## How it works

Everything is in two files:

- [`Dockerfile`](./Dockerfile): starts from `postgres:N`, installs the PGDG packages listed in [`extensions/pgdg.txt`](./extensions/pgdg.txt), and copies in the extensions that come from the authors' releases or are compiled in separate build stages. Compilers and headers never reach the final image.
- [`docker-bake.hcl`](./docker-bake.hcl): the list of PostgreSQL versions and their tags. CI reads it too.

Each extension has a functional test in `extensions/<name>/test.sql`.

To build and test locally (requires Docker with Buildx):

```sh
make test                   # build PG 18 and run the tests
make test PG_VERSION=16     # another version
make build-all              # build every version
```

## Documentation

- [Included extensions](./.docs/included-extensions.md): the full list, with setup notes.
- [Extensions](./.docs/extensions.md): adding or upgrading an extension or a PostgreSQL version.
- [Tests](./.docs/tests.md): how the tests and CI work.
- [Releases](./.docs/releases.md): versioning and how to publish a release.
- [Contributing](./CONTRIBUTING.md)

## License

MIT, see [LICENSE](./LICENSE).

# PostgreSQL Extensor

[![CI](https://github.com/ruxwez/postgres/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/ruxwez/postgres/actions/workflows/ci.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/ruxwez/postgres)](https://hub.docker.com/r/ruxwez/postgres)
[![Release](https://img.shields.io/github/v/release/ruxwez/postgres)](https://github.com/ruxwez/postgres/releases)
[![License: MIT](https://img.shields.io/github/license/ruxwez/postgres)](./LICENSE)

> [Leer en español](./README.es.md)

**The official PostgreSQL image with pgvector, PostGIS and pgmq preinstalled.** Vector search, geospatial queries and message queues in a single Postgres: no extra services, and no custom image to maintain.

- **Drop-in replacement** for `postgres`. Same entrypoint, same environment variables, same everything; only the extensions are added.
- **PostgreSQL 14 to 18**, on `linux/amd64` and `linux/arm64`. Both architectures are tested before every publish.
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

| | `postgres` | `pgvector/pgvector` | `postgis/postgis` | **`ruxwez/postgres`** |
|---|:-:|:-:|:-:|:-:|
| pgvector | — | ✅ | — | ✅ |
| PostGIS | — | — | ✅ | ✅ |
| pgmq | — | — | — | ✅ |
| `linux/arm64` (Apple Silicon, Graviton, Raspberry Pi) | ✅ | ✅ | — | ✅ |

<sub>Checked on the PostgreSQL 18 tags of each image (`pg18`, `18-3.6`) in October 2026.</sub>

## Tags

Pick a tag depending on how much change you're willing to accept:

| Tag | Example | Changes? |
|-----|---------|----------|
| `<pg>-v<X.Y.Z>` | `18-v1.0.0` | **Never.** Published once per release, never overwritten. |
| `<pg>-v<X>` | `18-v1` | With every `v1.x.y` release: compatible updates only. **Recommended.** |
| `<pg>` | `18` | On every build, including weekly rebuilds and breaking changes. |
| `latest` | | Same as the newest `<pg>` (currently `18`). |

The `vX.Y.Z` version belongs to this project, not to PostgreSQL: it changes when an extension changes. Each [release](https://github.com/ruxwez/postgres/releases) lists the exact PostgreSQL and extension versions of every image. See [Releases](./.docs/releases.md) for what each kind of bump means.

The versions are also in the image labels:

```sh
docker inspect ruxwez/postgres:18-v1 --format '{{json .Config.Labels}}'
```

For byte-for-byte reproducibility, pin a digest: `ruxwez/postgres@sha256:…`.

### Included extensions

| Extension | Version | Source |
|-----------|---------|--------|
| [pgvector](https://github.com/pgvector/pgvector) | 0.8.2 | Built from source |
| [PGMQ](https://github.com/pgmq/pgmq) | 1.11.1 | Built from source |
| [PostGIS](https://postgis.net/) | 3.6.4 | PGDG apt package (`postgresql-N-postgis-3`) |
| [contrib](https://www.postgresql.org/docs/current/contrib.html) | — | Included in the base image (`pg_stat_statements`, `pg_trgm`, …) |

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

- [`Dockerfile`](./Dockerfile): starts from `postgres:N`, installs the apt-packaged extensions, and copies in the ones compiled in separate build stages. Compilers and headers never reach the final image.
- [`docker-bake.hcl`](./docker-bake.hcl): the list of PostgreSQL versions and their tags. CI reads it too.

To build and test locally (requires Docker with Buildx):

```sh
make test                   # build PG 18 and run the tests
make test PG_VERSION=16     # another version
make build-all              # build every version
```

## Documentation

- [Extensions](./.docs/extensions.md): adding or upgrading an extension or a PostgreSQL version.
- [Tests](./.docs/tests.md): how the tests and CI work.
- [Releases](./.docs/releases.md): versioning and how to publish a release.
- [Contributing](./CONTRIBUTING.md)

## License

MIT, see [LICENSE](./LICENSE).

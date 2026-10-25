# PostgreSQL Extensor

> [Leer en español](./README.es.md)

Pre-built PostgreSQL Docker images with popular extensions.

## Purpose

Official `postgres` images don't include extensions like pgvector, PGMQ or PostGIS. Installing them by hand in every deployment is tedious and slow. This project publishes the official images with those extensions already installed, and nothing else changed.

## Docker images

Available on [Docker Hub](https://hub.docker.com/r/ruxwez/postgres):

PostgreSQL 14, 15, 16, 17 and 18, for `linux/amd64` and `linux/arm64`.

### Tags

Pick a tag depending on how much change you're willing to accept:

| Tag | Example | Changes? |
|-----|---------|----------|
| `<pg>-v<X.Y.Z>` | `18-v1.0.0` | **Never.** Published once per release, never overwritten. |
| `<pg>-v<X>` | `18-v1` | With every `v1.x.y` release: compatible updates only. |
| `<pg>` | `18` | On every build, including weekly rebuilds and breaking changes. |
| `latest` | | Same as the newest `<pg>` (currently `18`). |

The `vX.Y.Z` version belongs to this project, not to PostgreSQL: it changes when an extension changes. Each [release](https://github.com/ruxwez/postgres/releases) lists the exact PostgreSQL and extension versions of every image. See [Releases](./.docs/releases.md) for what each kind of bump means.

```sh
docker pull ruxwez/postgres:18-v1   # recommended for production
```

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

## How it works

Everything is in two files:

- [`Dockerfile`](./Dockerfile): starts from `postgres:N`, installs the apt-packaged extensions, and copies in the ones compiled in separate build stages. Compilers and headers never reach the final image.
- [`docker-bake.hcl`](./docker-bake.hcl): the list of PostgreSQL versions and their tags. CI reads it too.

## Local usage

Requires Docker with Buildx.

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

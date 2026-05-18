# PostgreSQL Extensor

> [Leer en español](./README.es.md)

Pre-built PostgreSQL Docker images with popular extensions.

## Purpose

Official `postgres` images don't include extensions like pgvector, PGMQ, or PostGIS. Installing them manually in every deployment is tedious and slow. This project solves that by building ready-to-use Docker images with extensions already compiled and installed.

The Go binary runs at Docker build time, auto-detects the PostgreSQL version, installs each extension, and then deletes itself. The result is a clean, optimized image.

## Docker Images

Available on [Docker Hub](https://hub.docker.com/r/ruxwez/postgres):

```sh
docker pull ruxwez/postgres:18
docker pull ruxwez/postgres:17
docker pull ruxwez/postgres:16
docker pull ruxwez/postgres:15
docker pull ruxwez/postgres:14
docker pull ruxwez/postgres:latest
```

Multi-architecture support: `linux/amd64` and `linux/arm64`.

### Included extensions

| Extension | Version | Installation |
|-----------|---------|-------------|
| [pgvector](https://github.com/pgvector/pgvector) | 0.8.2 | Build from source |
| [PGMQ](https://github.com/pgmq/pgmq) | 1.11.1 | Build from source |
| [PostGIS](https://postgis.net/) | 3 | apt package (`postgresql-N-postgis-3`) |
| [postgresql-contrib](https://www.postgresql.org/docs/current/contrib.html) | — | apt package (`pg_stat_statements`, etc.) |

## Local build

```sh
make build PG_VERSION=18
```

## Documentation

- [Tests](./.docs/tests.md) — How tests work and how to extend them.
- [Playgrounds](./.docs/playgrounds.md) — Architecture, versioning, and creating new playgrounds.

## License

MIT — see [LICENSE](./LICENSE).

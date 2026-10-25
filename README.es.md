# PostgreSQL Extensor

[![CI](https://github.com/ruxwez/postgres/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/ruxwez/postgres/actions/workflows/ci.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/ruxwez/postgres)](https://hub.docker.com/r/ruxwez/postgres)
[![Release](https://img.shields.io/github/v/release/ruxwez/postgres)](https://github.com/ruxwez/postgres/releases)
[![License: MIT](https://img.shields.io/github/license/ruxwez/postgres)](./LICENSE)

> [Read in English](./README.md)

**La imagen oficial de PostgreSQL con más de 80 extensiones preinstaladas**: pgvector, PostGIS, pgmq, TimescaleDB, pg_cron, pg_duckdb, Apache AGE, pg_graphql y [muchas más](./.docs/included-extensions.es.md). Búsqueda vectorial, consultas geoespaciales, colas, series temporales y analítica en un solo Postgres: sin servicios extra y sin tener que mantener una imagen propia.

- **Sustituye directamente** a `postgres`. Mismo entrypoint, mismas variables de entorno, misma configuración por defecto; no se activa nada hasta que haces `CREATE EXTENSION`.
- **PostgreSQL 14 a 18**, en `linux/amd64` y `linux/arm64`. Cada extensión tiene un test funcional, que se ejecuta en las dos arquitecturas antes de cada publicación.
- **Tags inmutables con versión** (`18-v1.0.0`): una actualización nunca te llega si no la pides.
- **Se reconstruye cada semana** con los parches de seguridad de la imagen base.

## Inicio rápido

```sh
docker run -d --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 ruxwez/postgres:18-v1
```

O con Docker Compose:

```yaml
services:
  db:
    image: ruxwez/postgres:18-v1
    environment:
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql   # PostgreSQL 17 o anterior: /var/lib/postgresql/data

volumes:
  pgdata:
```

Activa las extensiones que necesites en cada base de datos y úsalas juntas:

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

-- El sitio más parecido a "café" a menos de 5 km de la Puerta del Sol → Café Central
SELECT name
FROM places
WHERE ST_DWithin(location, 'POINT(-3.7037 40.4169)', 5000)
ORDER BY embedding <=> '[1, 0, 0]'
LIMIT 1;

-- Encola un trabajo en segundo plano para recalcular embeddings
SELECT pgmq.create('embeddings');
SELECT pgmq.send(queue_name => 'embeddings', msg => '{"place_id": 1}');
SELECT msg_id, message FROM pgmq.read(queue_name => 'embeddings', vt => 30, qty => 1);
```

## Por qué esta imagen

Si solo necesitas una extensión, su propia imagen es una gran opción. Esta es para cuando necesitas varias:

| | `postgres` | `pgvector/pgvector` | `postgis/postgis` | `pglayers-full` | **`ruxwez/postgres`** |
|---|:-:|:-:|:-:|:-:|:-:|
| Extensiones además de contrib | — | 1 | 1 | 80+ | 80+ |
| PostgreSQL 14–16 | ✅ | ✅ | ✅ | — | ✅ |
| `linux/arm64` (Apple Silicon, Graviton, Raspberry Pi) | ✅ | ✅ | — | ✅ | ✅ |
| Misma configuración por defecto que la oficial | ✅ | ✅ | ✅ | — (precarga librerías) | ✅ |

<sub>Comprobado en octubre de 2026 en los tags de PostgreSQL 14 y 18 de cada imagen. [pglayers](https://github.com/pglayers/pglayers) publica además cada extensión como una capa separada, lo que te encaja si quieres montar tu propia imagen.</sub>

## Tags

Elige el tag según cuántos cambios estés dispuesto a aceptar:

| Tag | Ejemplo | ¿Cambia? |
|-----|---------|----------|
| `<pg>-v<X.Y.Z>` | `18-v1.0.0` | **Nunca.** Se publica una vez por release y no se sobrescribe. |
| `<pg>-v<X>` | `18-v1` | Con cada release `v1.x.y`: solo cambios compatibles. **Recomendado.** |
| `<pg>` | `18` | En cada build, incluidos los rebuilds semanales y los cambios incompatibles. |
| `latest` | | Igual que el `<pg>` más reciente (ahora `18`). |

La versión `vX.Y.Z` es la de este proyecto, no la de PostgreSQL: cambia cuando cambia una extensión. Cada [release](https://github.com/ruxwez/postgres/releases) indica las versiones exactas de PostgreSQL y de las extensiones de cada imagen. En [Releases](./.docs/releases.es.md) se explica qué significa cada tipo de subida.

Cada imagen incluye también la lista de lo que contiene:

```sh
docker run --rm ruxwez/postgres:18-v1 cat /usr/share/postgres-extensor/extensions.txt
```

Para una reproducibilidad exacta, fija un digest: `ruxwez/postgres@sha256:…`.

### Extensiones incluidas

| Categoría | Extensiones |
|---|---|
| IA y vectores | pgvector, pgvectorscale |
| Geoespacial | PostGIS, pgRouting, H3, pgSphere |
| Búsqueda y texto | pg_textsearch (BM25), RUM, pg_bigm, pg_similarity, pgpcre, re2, icu_ext |
| Series temporales y analítica | TimescaleDB, pg_duckdb, pg_ivm, pg_incremental, hll, tdigest, roaringbitmap, … |
| Colas y tareas | pgmq, pg_cron, pg_background, pg_partman |
| JSON, documentos y APIs | DocumentDB, pg_graphql, pg_jsonschema, jsquery, http, pg_net, pgjwt, … |
| Tipos de datos | Apache AGE (grafos), pg_uuidv7, pg_hashids, ip4r, semver, periods, temporal_tables, … |
| Replicación y CDC | pglogical, wal2json, pg_failover_slots |
| Monitorización y rendimiento | pg_stat_monitor, pg_stat_kcache, pg_qualstats, hypopg, pg_hint_plan, pg_repack, pg_squeeze, … |
| Seguridad | pgaudit, PostgreSQL Anonymizer, pgsodium, credcheck, set_user, … |
| Datos externos | Supabase Wrappers, pg_clickhouse, tds_fdw |
| Desarrollo y compatibilidad | pgTAP, plpgsql_check, plprofiler, PLJS, orafce, pgtt, db2fce |

Más todo [contrib](https://www.postgresql.org/docs/current/contrib.html). En la [lista completa](./.docs/included-extensions.es.md) tienes los enlaces, cuáles necesitan `shared_preload_libraries` y las advertencias conocidas.

## Úsala en tests y CI

**GitHub Actions**, como service container:

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

**Testcontainers (Java).** Declárala como sustituta de `postgres` para que el módulo de PostgreSQL la acepte:

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

## Cómo funciona

Todo está en dos archivos:

- [`Dockerfile`](./Dockerfile): parte de `postgres:N`, instala los paquetes de PGDG listados en [`extensions/pgdg.txt`](./extensions/pgdg.txt) y copia las extensiones que vienen de las releases de sus autores o que se compilan en etapas de build separadas. Los compiladores y headers nunca llegan a la imagen final.
- [`docker-bake.hcl`](./docker-bake.hcl): la lista de versiones de PostgreSQL y sus tags. El CI también la lee.

Cada extensión tiene un test funcional en `extensions/<nombre>/test.sql`.

Para construir y probar en local (requiere Docker con Buildx):

```sh
make test                   # construye PG 18 y ejecuta los tests
make test PG_VERSION=16     # otra versión
make build-all              # construye todas las versiones
```

## Documentación

- [Extensiones incluidas](./.docs/included-extensions.es.md): la lista completa, con notas de configuración.
- [Extensiones](./.docs/extensions.es.md): añadir o actualizar una extensión o una versión de PostgreSQL.
- [Tests](./.docs/tests.es.md): cómo funcionan los tests y el CI.
- [Releases](./.docs/releases.es.md): versionado y cómo publicar una release.
- [Contribuir](./CONTRIBUTING.es.md)

## Licencia

MIT, ver [LICENSE](./LICENSE).

# PostgreSQL Extensor

[![CI](https://github.com/ruxwez/postgres/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/ruxwez/postgres/actions/workflows/ci.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/ruxwez/postgres)](https://hub.docker.com/r/ruxwez/postgres)
[![Release](https://img.shields.io/github/v/release/ruxwez/postgres)](https://github.com/ruxwez/postgres/releases)
[![License: MIT](https://img.shields.io/github/license/ruxwez/postgres)](./LICENSE)

> [Read in English](./README.md)

**La imagen oficial de PostgreSQL con pgvector, PostGIS y pgmq preinstalados.** Búsqueda vectorial, consultas geoespaciales y colas de mensajes en un solo Postgres: sin servicios extra y sin tener que mantener una imagen propia.

- **Sustituye directamente** a `postgres`. Mismo entrypoint, mismas variables de entorno, todo igual; solo se añaden las extensiones.
- **PostgreSQL 14 a 18**, en `linux/amd64` y `linux/arm64`. Las dos arquitecturas se prueban antes de cada publicación.
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

| | `postgres` | `pgvector/pgvector` | `postgis/postgis` | **`ruxwez/postgres`** |
|---|:-:|:-:|:-:|:-:|
| pgvector | — | ✅ | — | ✅ |
| PostGIS | — | — | ✅ | ✅ |
| pgmq | — | — | — | ✅ |
| `linux/arm64` (Apple Silicon, Graviton, Raspberry Pi) | ✅ | ✅ | — | ✅ |

<sub>Comprobado en los tags de PostgreSQL 18 de cada imagen (`pg18`, `18-3.6`) en octubre de 2026.</sub>

## Tags

Elige el tag según cuántos cambios estés dispuesto a aceptar:

| Tag | Ejemplo | ¿Cambia? |
|-----|---------|----------|
| `<pg>-v<X.Y.Z>` | `18-v1.0.0` | **Nunca.** Se publica una vez por release y no se sobrescribe. |
| `<pg>-v<X>` | `18-v1` | Con cada release `v1.x.y`: solo cambios compatibles. **Recomendado.** |
| `<pg>` | `18` | En cada build, incluidos los rebuilds semanales y los cambios incompatibles. |
| `latest` | | Igual que el `<pg>` más reciente (ahora `18`). |

La versión `vX.Y.Z` es la de este proyecto, no la de PostgreSQL: cambia cuando cambia una extensión. Cada [release](https://github.com/ruxwez/postgres/releases) indica las versiones exactas de PostgreSQL y de las extensiones de cada imagen. En [Releases](./.docs/releases.es.md) se explica qué significa cada tipo de subida.

Las versiones también están en los labels de la imagen:

```sh
docker inspect ruxwez/postgres:18-v1 --format '{{json .Config.Labels}}'
```

Para una reproducibilidad exacta, fija un digest: `ruxwez/postgres@sha256:…`.

### Extensiones incluidas

| Extensión | Versión | Origen |
|-----------|---------|--------|
| [pgvector](https://github.com/pgvector/pgvector) | 0.8.2 | Compilada desde el código fuente |
| [PGMQ](https://github.com/pgmq/pgmq) | 1.11.1 | Compilada desde el código fuente |
| [PostGIS](https://postgis.net/) | 3.6.4 | Paquete apt de PGDG (`postgresql-N-postgis-3`) |
| [contrib](https://www.postgresql.org/docs/current/contrib.html) | — | Incluida en la imagen base (`pg_stat_statements`, `pg_trgm`, …) |

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

- [`Dockerfile`](./Dockerfile): parte de `postgres:N`, instala las extensiones que hay en apt y copia las que se compilan en etapas de build separadas. Los compiladores y headers nunca llegan a la imagen final.
- [`docker-bake.hcl`](./docker-bake.hcl): la lista de versiones de PostgreSQL y sus tags. El CI también la lee.

Para construir y probar en local (requiere Docker con Buildx):

```sh
make test                   # construye PG 18 y ejecuta los tests
make test PG_VERSION=16     # otra versión
make build-all              # construye todas las versiones
```

## Documentación

- [Extensiones](./.docs/extensions.es.md): añadir o actualizar una extensión o una versión de PostgreSQL.
- [Tests](./.docs/tests.es.md): cómo funcionan los tests y el CI.
- [Releases](./.docs/releases.es.md): versionado y cómo publicar una release.
- [Contribuir](./CONTRIBUTING.es.md)

## Licencia

MIT, ver [LICENSE](./LICENSE).

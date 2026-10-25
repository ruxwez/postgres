# PostgreSQL Extensor

> [Read in English](./README.md)

Imágenes Docker de PostgreSQL con extensiones populares preinstaladas.

## Propósito

Las imágenes oficiales de `postgres` no incluyen extensiones como pgvector, PGMQ o PostGIS. Instalarlas a mano en cada despliegue es tedioso y lento. Este proyecto publica las imágenes oficiales con esas extensiones ya instaladas, sin cambiar nada más.

## Imágenes Docker

Disponibles en [Docker Hub](https://hub.docker.com/r/ruxwez/postgres):

PostgreSQL 14, 15, 16, 17 y 18, para `linux/amd64` y `linux/arm64`.

### Tags

Elige el tag según cuántos cambios estés dispuesto a aceptar:

| Tag | Ejemplo | ¿Cambia? |
|-----|---------|----------|
| `<pg>-v<X.Y.Z>` | `18-v1.0.0` | **Nunca.** Se publica una vez por release y no se sobrescribe. |
| `<pg>-v<X>` | `18-v1` | Con cada release `v1.x.y`: solo cambios compatibles. |
| `<pg>` | `18` | En cada build, incluidos los rebuilds semanales y los cambios incompatibles. |
| `latest` | | Igual que el `<pg>` más reciente (ahora `18`). |

La versión `vX.Y.Z` es la de este proyecto, no la de PostgreSQL: cambia cuando cambia una extensión. Cada [release](https://github.com/ruxwez/postgres/releases) indica las versiones exactas de PostgreSQL y de las extensiones de cada imagen. En [Releases](./.docs/releases.es.md) se explica qué significa cada tipo de subida.

```sh
docker pull ruxwez/postgres:18-v1   # recomendado para producción
```

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

## Cómo funciona

Todo está en dos archivos:

- [`Dockerfile`](./Dockerfile): parte de `postgres:N`, instala las extensiones que hay en apt y copia las que se compilan en etapas de build separadas. Los compiladores y headers nunca llegan a la imagen final.
- [`docker-bake.hcl`](./docker-bake.hcl): la lista de versiones de PostgreSQL y sus tags. El CI también la lee.

## Uso local

Requiere Docker con Buildx.

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

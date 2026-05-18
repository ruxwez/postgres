# PostgreSQL Extensor

> [Read in English](./README.md)

Imágenes Docker de PostgreSQL con extensiones populares preinstaladas.

## Propósito

Las imágenes oficiales de `postgres` no incluyen extensiones como pgvector, PGMQ o PostGIS. Instalarlas manualmente en cada despliegue es tedioso y lento. Este proyecto resuelve el problema construyendo imágenes Docker listas para usar, con las extensiones ya compiladas e instaladas.

El binario Go se ejecuta en tiempo de build de la imagen Docker, detecta automáticamente la versión de PostgreSQL, instala cada extensión y luego se elimina a sí mismo. El resultado es una imagen limpia y optimizada.

## Imágenes Docker

Disponibles en [Docker Hub](https://hub.docker.com/r/ruxwez/postgres):

```sh
docker pull ruxwez/postgres:18
docker pull ruxwez/postgres:17
docker pull ruxwez/postgres:16
docker pull ruxwez/postgres:15
docker pull ruxwez/postgres:14
docker pull ruxwez/postgres:latest
```

Soporte multi-arquitectura: `linux/amd64` y `linux/arm64`.

### Extensiones incluidas

| Extensión | Versión | Instalación |
|-----------|---------|-------------|
| [pgvector](https://github.com/pgvector/pgvector) | 0.8.2 | Compilación desde fuente |
| [PGMQ](https://github.com/pgmq/pgmq) | 1.11.1 | Compilación desde fuente |
| [PostGIS](https://postgis.net/) | 3 | Paquete apt (`postgresql-N-postgis-3`) |
| [postgresql-contrib](https://www.postgresql.org/docs/current/contrib.html) | — | Paquete apt (`pg_stat_statements`, etc.) |

## Build local

```sh
make build PG_VERSION=18
```

## Documentación

- [Tests](./.docs/tests.es.md) — Cómo funcionan los tests y cómo ampliarlos.
- [Playgrounds](./.docs/playgrounds.es.md) — Arquitectura, versionado y creación de nuevos playgrounds.

## Licencia

MIT — ver [LICENSE](./LICENSE).

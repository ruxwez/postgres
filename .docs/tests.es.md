# Tests

> [Read in English](./tests.md)

Los tests comprueban la **imagen final**: arrancan un contenedor y usan cada extensión dentro de un PostgreSQL real.

## Cómo ejecutarlos

```sh
make test                   # construye PG 18 para tu plataforma y lo prueba
make test PG_VERSION=14

./tests/run.sh <imagen>     # prueba una imagen ya construida
```

## Qué hace `tests/run.sh`

1. Arranca la imagen con `POSTGRES_PASSWORD=postgres`.
2. Espera a que PostgreSQL acepte conexiones TCP. El servidor temporal de inicialización del entrypoint solo escucha en el socket unix, así que la espera no termina antes de tiempo.
3. Para cada `extensions/*/test.sql`, crea una base de datos nueva, ejecuta el archivo con `ON_ERROR_STOP=1` e imprime `PASS` (con las versiones instaladas) o `FAIL` (con el error).
4. Termina con un código distinto de cero si algún test falla, después de ejecutarlos todos.

```
PASS  contrib  (pg_stat_statements 1.12, pg_trgm 1.6)
PASS  pgmq  (pgmq 1.11.1)
PASS  pgvector  (vector 0.8.2)
PASS  postgis  (postgis 3.6.4)
All tests passed.
```

Para probar una extensión nueva, añade su `test.sql` (ver [Extensiones](./extensions.es.md)). No hace falta registrarlo en ningún sitio.

## CI

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) se ejecuta en cada PR, en `main`, en los tags `vX.Y.Z`, cada semana y manualmente:

1. **Prepare:** lee las versiones de `docker-bake.hcl`. Si es un tag de release, comprueba además que la release es válida y que no está publicada todavía (ver [Releases](./releases.es.md)).
2. **Build y test** de cada versión en `amd64` y `arm64`, con runners nativos (sin emulación).
3. **All builds passed:** un único check, para la protección de rama.
4. **Publish** (no en PRs): sube exactamente las imágenes que se probaron y crea los tags como manifests multi-arquitectura. No se publica nada si alguna versión falla en cualquiera de las dos arquitecturas.
5. **GitHub release** (solo en tags de release): crea la release con las versiones que reportan los tests.

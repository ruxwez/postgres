# Extensiones

> [Read in English](./extensions.md)

Cada extensión tiene dos partes:

1. **Cómo se instala**: una línea en [`extensions/pgdg.txt`](../extensions/pgdg.txt) o unas pocas líneas en el [`Dockerfile`](../Dockerfile).
2. **Cómo se prueba**: `extensions/<nombre>/test.sql`.

No hay más código que tocar. La lista completa de lo que se incluye está en [Extensiones incluidas](./included-extensions.es.md).

## Añadir una extensión

Elige la primera opción que funcione, en este orden.

### Opción A: está empaquetada en PGDG (preferida)

Busca `postgresql-<major>-<paquete>` en [apt.postgresql.org](https://apt.postgresql.org/pub/repos/apt/pool/main/) y mira qué versiones tiene:

```sh
docker run --rm postgres:18 bash -c 'apt-get update -qq && apt-cache madison postgresql-18-<paquete>'
```

Si existe la misma versión upstream para todas las versiones mayores soportadas, añade una línea a `extensions/pgdg.txt`:

```
mi-paquete              1.2.3
```

Si la versión cambia según la versión mayor, o el paquete no existe para alguna, añade una línea por versión mayor:

```
mi-paquete/17           2.0.1
mi-paquete/18           2.1.0
```

La versión es la upstream, sin la revisión de Debian: `1.2.3` cubre `1.2.3-1.pgdg13+1`. Renovate actualiza estas líneas y las agrupa en un PR semanal.

### Opción B: los autores publican paquetes precompilados

Si los autores adjuntan a sus releases un `.deb` (o un `.zip` con uno) por cada versión mayor de PostgreSQL y arquitectura, añádelo a la etapa `prebuilt`. `fetch-deb` lo descarga y se queda solo con sus archivos de PostgreSQL:

```dockerfile
# arriba, con las demás versiones
# renovate: datasource=github-releases depName=owner/mi-extension
ARG MI_EXTENSION_VERSION=1.2.3

# en la etapa prebuilt
ARG MI_EXTENSION_VERSION
RUN fetch-deb "https://github.com/owner/mi-extension/releases/download/v${MI_EXTENSION_VERSION}/mi-extension-pg${PG_MAJOR}-${TARGETARCH}.deb"
```

### Opción C: compilarla desde el código fuente

Añade una línea a la etapa `source`. `pgxs-build` descarga un tag (o un commit) y hace `make install` en `/out`:

```dockerfile
# arriba, con las demás versiones
# renovate: datasource=github-tags depName=owner/mi-extension
ARG MI_EXTENSION_VERSION=1.2.3

# en la etapa source
ARG MI_EXTENSION_VERSION
RUN pgxs-build https://github.com/owner/mi-extension.git "v${MI_EXTENSION_VERSION}"
```

Argumentos opcionales: un subdirectorio y después argumentos extra de `make` (`pgxs-build URL TAG subdir USE_PGXS=1`). Si la extensión no soporta las versiones mayores antiguas, pon delante `MIN_PG_MAJOR=16` para saltárselas. Si el build necesita paquetes `-dev`, añádelos al `apt-get install` de la etapa `source`; no llegan a la imagen final. Las librerías de runtime van en el `apt-get install` de la etapa final.

El comentario `# renovate:` justo encima del `ARG` permite que Renovate abra un PR cada vez que salga una versión nueva. Mantén el mismo formato.

## Escribir el test

Crea `extensions/<nombre>/test.sql`. Tiene que **usar** la extensión, no solo crearla, y fallar si el resultado es incorrecto. `assert_true(condición, mensaje)` está disponible en todas las bases de datos de test:

```sql
CREATE EXTENSION mi_extension;

SELECT assert_true(mi_funcion(1) = 2, 'mi_extension: mi_funcion()');
```

`tests/run.sh` lo detecta automáticamente. Cada test se ejecuta en una base de datos nueva, todos en el mismo servidor. Estos archivos opcionales en el mismo directorio cambian ese comportamiento:

| Archivo | Contenido | Efecto |
|---|---|---|
| `server.conf` | Líneas de `postgresql.conf`, p. ej. `shared_preload_libraries = 'mi_extension'` | Se aplican al servidor de test. Los valores de `shared_preload_libraries` de todas las extensiones se combinan. |
| `pg-versions` | Versiones mayores soportadas, p. ej. `17 18` | En las demás versiones el test sale como `SKIP` en vez de fallar. |
| `database` | Un nombre de base de datos, p. ej. `postgres` | El test se ejecuta ahí en vez de en una base de datos nueva (lo necesitan pg_cron y las extensiones que dependen de ella). |
| `isolated` | Por qué la extensión no puede compartir servidor | El test se ejecuta en un servidor propio, solo con su `server.conf`. |

Por último, añade la extensión a [Extensiones incluidas](./included-extensions.es.md) y a la tabla de categorías del README.

## Actualizar una extensión

Cambia su versión en `extensions/pgdg.txt` o en su `ARG` arriba del todo en el Dockerfile. Renovate abre estos PRs por ti.

Una vez hecho el merge, el cambio solo llega a `18` y `latest`. Para llevarlo a `18-v1`, saca una release (en [Releases](./releases.es.md) se explica qué número subir).

## Añadir o quitar una versión de PostgreSQL

Edita la lista `major` en [`docker-bake.hcl`](../docker-bake.hcl). Para mover `:latest` a una versión nueva, cambia también `LATEST`. El CI construye y prueba todas las versiones de esa lista. Si alguna extensión no está disponible para una versión nueva, ponle un archivo `pg-versions` (con las líneas por versión mayor o el `MIN_PG_MAJOR` correspondientes), o espera a que lo esté.

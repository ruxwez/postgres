# Extensiones

> [Read in English](./extensions.md)

Cada extensión tiene dos partes:

1. **Cómo se instala**, en el [`Dockerfile`](../Dockerfile).
2. **Cómo se prueba**, en `extensions/<nombre>/test.sql`.

No hay más código que tocar.

## Añadir una extensión

### Opción A: está empaquetada en PGDG (preferida)

Busca `postgresql-<major>-<nombre>` en [apt.postgresql.org](https://apt.postgresql.org/pub/repos/apt/pool/main/). Tiene que existir para todas las versiones soportadas.

Declara su versión arriba del todo en el Dockerfile. El comentario `# renovate:` le indica a Renovate el índice de PGDG, para que abra un PR cuando se empaquete una versión nueva:

```dockerfile
# renovate: datasource=deb depName=postgresql-18-mi-extension registryUrl=https://apt.postgresql.org/pub/repos/apt?suite=trixie-pgdg&components=main&binaryArch=amd64
ARG MI_EXTENSION_VERSION=1.2.3
```

`suite` es la versión de Debian de la imagen base (hoy `trixie`) seguida de `-pgdg`. Puedes comprobarla con `docker run --rm postgres:18 cat /etc/os-release`.

Después, añádela fijada al `apt-get install` de la etapa final, y a los labels:

```dockerfile
ARG MI_EXTENSION_VERSION
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      "postgresql-${PG_MAJOR}-postgis-3=${POSTGIS_VERSION}+*" \
      "postgresql-${PG_MAJOR}-mi-extension=${MI_EXTENSION_VERSION}*" \
 && rm -rf /var/lib/apt/lists/*
LABEL ... \
      io.github.ruxwez.postgres.mi-extension.version="${MI_EXTENSION_VERSION}"
```

El `*` final cubre la revisión de Debian (`1.2.3-1.pgdg13+1`). Usa `+*` cuando la versión del paquete lleve `+dfsg` o algo parecido, como pasa con PostGIS. Puedes ver las versiones disponibles con:

```sh
docker run --rm postgres:18 bash -c 'apt-get update -qq && apt-cache madison postgresql-18-mi-extension'
```

PGDG suele mantener varias versiones anteriores en su índice, así que la versión fijada sigue funcionando un tiempo después de que salga una nueva. Cuando una versión desaparece del índice, el build falla con `Version '…' was not found` hasta que se hace merge del PR de Renovate.

La imagen oficial base define `PG_MAJOR`.

### Opción B: compilarla desde el código fuente

Declara su versión arriba del todo en el Dockerfile, junto a las demás:

```dockerfile
# renovate: datasource=github-tags depName=owner/mi-extension
ARG MI_EXTENSION_VERSION=1.2.3
```

El comentario `# renovate:` justo encima del `ARG` permite que Renovate abra un PR cada vez que salga un tag nuevo. Mantén el mismo formato.

Añade una etapa encima de `build-base`. Tiene que instalar en `/out` (con `DESTDIR`):

```dockerfile
FROM build-base AS mi-extension
ARG MI_EXTENSION_VERSION
RUN git clone --depth 1 --branch "v${MI_EXTENSION_VERSION}" https://github.com/owner/mi-extension.git /src \
 && make -C /src \
 && make -C /src install DESTDIR=/out
```

En la etapa final, cópiala y añade su versión a los labels:

```dockerfile
ARG MI_EXTENSION_VERSION
COPY --from=mi-extension /out/ /
LABEL ... \
      io.github.ruxwez.postgres.mi-extension.version="${MI_EXTENSION_VERSION}"
```

Si el build necesita más paquetes, añádelos a `build-base`. No llegan a la imagen final.

### Después, en ambos casos

Crea `extensions/<nombre>/test.sql`. Tiene que **usar** la extensión, no solo crearla, y lanzar un error si el resultado es incorrecto:

```sql
CREATE EXTENSION mi_extension;

DO $$
BEGIN
  IF mi_funcion(1) <> 2 THEN
    RAISE EXCEPTION 'mi_extension: resultado inesperado';
  END IF;
END $$;
```

`tests/run.sh` lo detecta automáticamente. Por último, añade la extensión a la tabla del README.

## Actualizar una extensión

Cambia su `ARG *_VERSION` arriba del todo en el Dockerfile. Renovate abre estos PRs por ti, tanto para los paquetes apt como para las extensiones que se compilan.

Una vez hecho el merge, el cambio solo llega a `18` y `latest`. Para llevarlo a `18-v1`, saca una release (en [Releases](./releases.es.md) se explica qué número subir).

## Añadir o quitar una versión de PostgreSQL

Edita la lista `major` en [`docker-bake.hcl`](../docker-bake.hcl). Para mover `:latest` a una versión nueva, cambia también `LATEST`. El CI construye y prueba todas las versiones de esa lista, así que si alguna extensión no está disponible para una versión, el build falla.

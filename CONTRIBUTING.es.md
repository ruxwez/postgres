# Contribuir

> [Read in English](./CONTRIBUTING.md)

Gracias por tu interés en contribuir a PostgreSQL Extensor.

## Reportar problemas

Usa las plantillas de `.github/ISSUE_TEMPLATE/`:

- **Bug report:** para errores o comportamientos inesperados.
- **Feature request:** para proponer nuevas extensiones o funcionalidades.
- **Custom:** para cualquier otra cosa.

## Pull Requests

1. Haz un fork del repositorio.
2. Crea una rama con un nombre descriptivo: `feat/pg-partman`, `fix/pgvector-build`.
3. Ejecuta los tests de al menos una versión en local:

   ```sh
   make test PG_VERSION=18
   ```

4. Si añades una extensión, sigue [Extensiones](./.docs/extensions.es.md). Se reduce a unas líneas en el `Dockerfile`, un `extensions/<nombre>/test.sql` y una fila en la tabla del README.
5. Abre el PR contra `main`. El CI construye y prueba todas las versiones en amd64 y arm64.

Al hacer merge solo se actualizan los tags móviles (`18`, `latest`). Los mantenedores sacan releases para actualizar los tags con versión (ver [Releases](./.docs/releases.es.md)).

## Pautas

- Usa paquetes apt de PGDG antes que compilar desde el código fuente.
- Fija la versión de todas las extensiones, también las de apt, con un `ARG` y un comentario `# renovate:`.
- Las herramientas de compilación van en `build-base`, nunca en la etapa final.

## Estructura del proyecto

```
Dockerfile            Definición de la imagen (una etapa por extensión compilada)
docker-bake.hcl       Versiones de PostgreSQL y tags
extensions/<nombre>/  test.sql de cada extensión
tests/run.sh          Ejecuta todos los test.sql contra una imagen
.github/workflows/    CI: build, test, publicación, release
.github/scripts/      Scripts que usa el CI (release notes)
.docs/                Documentación
```

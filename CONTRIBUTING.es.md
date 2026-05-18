# Contribuyendo

> [Read in English](./CONTRIBUTING.md)

Gracias por tu interés en contribuir a PostgreSQL Extensor.

## Reportar issues

Usa las plantillas en `.github/ISSUE_TEMPLATE/`:

- **Bug report** — para errores o comportamientos inesperados.
- **Feature request** — para sugerir nuevas extensiones o funcionalidades.
- **Custom** — para cualquier otro caso.

## Pull Requests

1. Crea un fork del repositorio.
2. Crea una rama con un nombre descriptivo: `feat/pg-partman`, `fix/pgvector-build`.
3. Asegúrate de que los tests pasen para todas las versiones de PostgreSQL:

   ```sh
   make test
   make runtime-test PG_VERSION=18
   ```

4. Si agregas una nueva extensión, incluye:
   - El playground en `extensions/`.
   - El registro en `extensions/extensions.go`.
   - La verificación en `.docker/runtime-test.sql`.
   - Actualiza la documentación relevante en `.docs/`.

5. Abre el PR contra `main`. Los workflows de CI ejecutarán los tests automáticamente para todas las versiones soportadas.

## Guías

- Sigue el estilo del código existente.
- No agregues dependencias innecesarias a `go.mod`.
- Los playgrounds deben ser idempotentes y limpiar los archivos temporales.
- Documenta los rangos de versiones semver claramente.

## Estructura del proyecto

```
.docker/          — Dockerfiles y scripts de test
.docs/            — Documentación
.github/          — Workflows CI/CD y templates
extensions/       — Definición de playgrounds
instance/         — Detección del entorno (OS, versión PG)
plyd/             — Motor de playgrounds (core framework)
utils/            — Utilidades de versionado semver
```

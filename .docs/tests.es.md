# Tests

> [Read in English](./tests.md)

Este proyecto utiliza **tests de integración** en lugar de tests unitarios de Go (`_test.go`). La razón es que el propósito del binario es ejecutarse dentro de una imagen Docker en tiempo de build, interactuando directamente con el sistema operativo (apt, git, make, pg_config, etc.). No hay lógica de negocio aislable que justifique tests unitarios tradicionales.

---

## `make test` — Build test

```sh
make test
```

Construye la imagen Docker usando `.docker/Dockerfile.test`. Este Dockerfile ejecuta el binario `./main` dentro de un contenedor `postgres:13` y verifica que todo el pipeline de instalación de extensiones compile y se ejecute sin errores. Al finalizar, la imagen se elimina.

- **Propósito:** Validación rápida de que el código compila y los playgrounds no fallan.
- **Limitación:** Usa PostgreSQL 13 fijo, independientemente de `PG_VERSION`.

---

## `make runtime-test` — Runtime test

```sh
make runtime-test           # PG_VERSION=18 por defecto
PG_VERSION=17 make runtime-test
```

Ejecuta el script `.docker/runtime-test.sh`, que:

1. Construye la imagen Docker de producción (`.docker/Dockerfile`).
2. Inicia un contenedor con `POSTGRES_PASSWORD=postgres`.
3. Espera a que PostgreSQL esté listo (`pg_isready`).
4. Ejecuta `.docker/runtime-test.sql` contra la base de datos vía `psql`.

El script SQL verifica:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgmq;
CREATE EXTENSION IF NOT EXISTS postgis;

-- Confirma que las extensiones están instaladas
SELECT * FROM pg_extension WHERE extname IN ('vector', 'pgmq', 'postgis');

-- Confirma que contrib está disponible
SELECT * FROM pg_available_extensions WHERE name = 'pg_stat_statements';
```

- **Propósito:** Validación real de que todas las extensiones se instalan correctamente y son funcionales dentro de PostgreSQL.
- **Versiones:** Se ejecuta contra la versión de PostgreSQL indicada por `PG_VERSION`.

---

## CI — GitHub Actions

En `pr-test.yml`, cada Pull Request ejecuta la runtime test matrix para todas las versiones soportadas (`14`, `15`, `16`, `17`, `18`, `latest`) en `linux/amd64`. Esto asegura que cualquier cambio funcione en todo el rango de versiones objetivo.

---

## Cómo ampliar los tests

### Agregar verificación de una extensión nueva

Edita `.docker/runtime-test.sql`:

```sql
CREATE EXTENSION IF NOT EXISTS mi_extension;
SELECT * FROM pg_extension WHERE extname = 'mi_extension';
```

### Agregar un nuevo paso en runtime-test.sh

Si necesitas lógica adicional antes o después de los tests SQL (por ejemplo, copiar archivos, verificar permisos), edita `.docker/runtime-test.sh`.

### Tests unitarios (futuro)

Si en el futuro se extrae lógica reutilizable (por ejemplo, el parseo de versiones o el matching de handlers), se pueden agregar archivos `_test.go` en los paquetes correspondientes y ejecutarlos con:

```sh
go test ./...
```

Actualmente no existen porque la lógica del proyecto está fuertemente acoplada al entorno Docker.

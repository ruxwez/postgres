# Cómo añadir una nueva versión de PostgreSQL

Este documento explica cómo añadir soporte para una nueva versión de PostgreSQL al repositorio.

## Pasos para añadir una nueva versión

### 1. Crear la estructura de carpetas

Crea una nueva carpeta con el número de la versión mayor de PostgreSQL:

```bash
mkdir 16  # Para PostgreSQL 16
```

### 2. Crear el Dockerfile

Copia el Dockerfile de una versión existente y modifica las referencias de versión:

```bash
cp 17/Dockerfile 16/
```

Edita `16/Dockerfile` y cambia:
- `FROM postgres:17` → `FROM postgres:16`
- `postgresql-17-postgis-3` → `postgresql-16-postgis-3`
- `postgresql-17-postgis-3-scripts` → `postgresql-16-postgis-3-scripts`
- `postgresql-server-dev-17` → `postgresql-server-dev-16`

### 3. Copiar archivos de configuración

```bash
cp 17/init.sql 16/
cp 17/docker-compose.yml 16/
```

### 4. Actualizar el GitHub Action

Edita `.github/workflows/docker-image.yml` y añade la nueva versión a la matriz:

```yaml
strategy:
  matrix:
    postgres-version: [15, 16, 17]  # Añade la nueva versión aquí
```

### 5. Actualizar el README

Actualiza el `README.md` para documentar la nueva versión disponible.

## Estructura esperada

Después de añadir una nueva versión, deberías tener:

```
16/
├── Dockerfile
├── docker-compose.yml
└── init.sql
```

## Tags que se generarán

El GitHub Action automáticamente creará tags con el prefijo de la versión:

- `ruxwez/postgres:16-latest`
- `ruxwez/postgres:16-main`
- `ruxwez/postgres:16-YYYYMMDD-HHmmss`

## Verificación

Para verificar que todo funciona correctamente:

1. Haz commit y push de los cambios
2. El GitHub Action debería buildear automáticamente todas las versiones
3. Verifica que las imágenes aparezcan en Docker Hub con los tags correctos

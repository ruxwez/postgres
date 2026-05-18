# Playgrounds

> [Read in English](./playgrounds.md)

Un **playground** es la unidad fundamental de instalación de extensiones. Cada playground representa un paso en el pipeline que transforma una imagen base `postgres:N` en una imagen con extensiones preinstaladas.

---

## Arquitectura

Cada playground se define en el paquete `extensions/` y se registra en la variable global `Playgrounds` (`extensions/extensions.go`), que es un slice ordenado de `[]*plyd.Playground`.

### Estructura de un Playground

```go
type Playground struct {
    Name     string
    handlers HandlersList
}
```

Cada playground contiene una lista de **handlers**, donde cada handler asocia un **rango de versiones semver** con una **función ejecutora**:

```go
type Handler struct {
    Range  string       // Ej: ">=14.0.0, <19.0.0"
    Runner HandlerFunc  // func(ins *instance.InstanceInfo) error
}
```

### Ejecución (`Run`)

```go
func (p *Playground) Run(ins *instance.InstanceInfo) {
    handler := p.matchHandler(ins.PostgreSQL.Version)
    if handler == nil {
        log.Printf("[WARNING] No handler for PG %s in playground '%s'", ...)
        return  // No es fatal — el playground simplemente se salta
    }
    handler.Runner(ins)
}
```

---

## Versionado

El versionado usa **semver 2.0** mediante la librería `github.com/Masterminds/semver/v3`.

### Flujo de matching

1. Se detecta la versión de PostgreSQL ejecutando `postgres --version`.
2. Se normaliza a semver canónico (ej: `"17"` → `"17.0.0"`).
3. `matchHandler` recorre los handlers en orden:
   - Primero busca coincidencia exacta de string.
   - Luego evalúa cada rango como `semver.Constraint`.
4. Retorna el primer handler que coincida.

### Orden de handlers

Los handlers se ordenan automáticamente en `NewHandlersList`:
- **Versiones exactas primero** (ej: `"17.2.0"`), ascendente.
- **Rangos después** (ej: `">=14.0.0, <19.0.0"`), orden alfabético.

Esto permite tener overrides específicos por versión antes de caer en rangos genéricos.

### Ejemplo

```go
var miExtension = plyd.New("mi-extension",
    plyd.NewHandlersList(
        plyd.NewHandler(">=16.0.0", func(ins *instance.InstanceInfo) error {
            return plyd.Run("apt-get install -y mi-extension")
        }),
        plyd.NewHandler(">=14.0.0, <16.0.0", func(ins *instance.InstanceInfo) error {
            return plyd.Run("apt-get install -y mi-extension-old")
        }),
    ),
)
```

---

## Playgrounds por defecto (orden de ejecución)

El orden en `extensions/extensions.go` es crítico:

| # | Playground | Archivo | Propósito |
|---|-----------|---------|-----------|
| 1 | `build-deps-install` | `builddeps_install.go` | Instala `git`, `make`, `gcc`, `postgresql-server-dev-MAYOR` |
| 2 | `pgmq` | `pgmq.go` | Clona, compila e instala [PGMQ](https://github.com/pgmq/pgmq) v1.11.1 |
| 3 | `pgvector` | `pgvector.go` | Clona, compila e instala [pgvector](https://github.com/pgvector/pgvector) v0.8.2 |
| 4 | `postgis` | `postgis.go` | Instala `postgresql-MAYOR-postgis-3` vía apt |
| 5 | `postgres-contrib` | `postgrescontrib.go` | Instala `postgresql-MAYOR` (contrib) vía apt |
| 6 | `build-deps-remove` | `builddeps_remove.go` | Desinstala dependencias de build y limpia apt |

### ¿Por qué este orden?

1. **Primero** se instalan las herramientas de build (necesarias para compilar pgmq y pgvector desde fuente).
2. **Luego** se compilan e instalan las extensiones que requieren build desde fuente (pgmq, pgvector).
3. **Después** se instalan las extensiones vía apt (postgis, contrib), que necesitan `postgresql-server-dev-MAYOR` ya presente.
4. **Al final** se eliminan las herramientas de build para mantener la imagen final ligera.

---

## Versiones PostgreSQL soportadas

Actualmente: **14, 15, 16, 17, 18** (y `latest` que apunta a la más reciente).

Todos los playgrounds usan el rango `>=14.0.0, <19.0.0`. Para ampliar el soporte (ej: PG 19), basta con actualizar los rangos.

---

## Cómo crear un nuevo playground

### 1. Crear el archivo de extensión

En `extensions/`, crea un archivo como `miextension.go`:

```go
package extensions

import (
    "postgres-extensor/instance"
    "postgres-extensor/plyd"
)

var miExtension = plyd.New("mi-extension",
    plyd.NewHandlersList(
        plyd.NewHandler(">=14.0.0, <19.0.0", func(ins *instance.InstanceInfo) error {
            return plyd.Run("apt-get install -y postgresql-" + ins.PostgreSQL.Mayor + "-mi-extension")
        }),
    ),
)
```

### 2. Registrarlo en el orden correcto

Edita `extensions/extensions.go` y agrégalo al slice `Playgrounds` en la posición adecuada:

```go
var Playgrounds = []*plyd.Playground{
    buildDepsInstall,
    pgmq,
    pgvector,
    miExtension,       // <-- Nuevo
    postgis,
    postgresContrib,
    buildDepsRemove,
}
```

### 3. Verificar la instalación

Tu handler debería verificar que la extensión quedó instalada:

```go
verification := "test -f $(pg_config --sharedir)/extension/mi_extension.control"
```

### 4. Agregar cobertura en tests

Edita `.docker/runtime-test.sql` para incluir la nueva extensión.

### 5. Build y test

```sh
make build PG_VERSION=18
make runtime-test PG_VERSION=18
```

# Playgrounds

> [Leer en español](./playgrounds.es.md)

A **playground** is the fundamental unit of extension installation. Each playground represents a step in the pipeline that transforms a `postgres:N` base image into an image with pre-installed extensions.

---

## Architecture

Each playground is defined in the `extensions/` package and registered in the global `Playgrounds` slice (`extensions/extensions.go`), an ordered `[]*plyd.Playground`.

### Playground struct

```go
type Playground struct {
    Name     string
    handlers HandlersList
}
```

Each playground contains a list of **handlers**, where each handler associates a **semver version range** with an **executor function**:

```go
type Handler struct {
    Range  string       // e.g. ">=14.0.0, <19.0.0"
    Runner HandlerFunc  // func(ins *instance.InstanceInfo) error
}
```

### Execution (`Run`)

```go
func (p *Playground) Run(ins *instance.InstanceInfo) {
    handler := p.matchHandler(ins.PostgreSQL.Version)
    if handler == nil {
        log.Printf("[WARNING] No handler for PG %s in playground '%s'", ...)
        return  // Non-fatal — the playground simply skips
    }
    handler.Runner(ins)
}
```

---

## Versioning

Versioning uses **semver 2.0** via `github.com/Masterminds/semver/v3`.

### Matching flow

1. The PostgreSQL version is detected by running `postgres --version`.
2. It is normalized to canonical semver (e.g. `"17"` → `"17.0.0"`).
3. `matchHandler` iterates over handlers:
   - First tries exact string match.
   - Then evaluates each range as a `semver.Constraint`.
4. Returns the first matching handler.

### Handler ordering

Handlers are automatically sorted in `NewHandlersList`:
- **Exact versions first** (e.g. `"17.2.0"`), ascending.
- **Ranges after** (e.g. `">=14.0.0, <19.0.0"`), alphabetical order.

This allows version-specific overrides before falling back to generic ranges.

### Example

```go
var myExtension = plyd.New("my-extension",
    plyd.NewHandlersList(
        plyd.NewHandler(">=16.0.0", func(ins *instance.InstanceInfo) error {
            return plyd.Run("apt-get install -y my-extension")
        }),
        plyd.NewHandler(">=14.0.0, <16.0.0", func(ins *instance.InstanceInfo) error {
            return plyd.Run("apt-get install -y my-extension-old")
        }),
    ),
)
```

---

## Default playgrounds (execution order)

The order in `extensions/extensions.go` is critical:

| # | Playground | File | Purpose |
|---|-----------|------|---------|
| 1 | `build-deps-install` | `builddeps_install.go` | Installs `git`, `make`, `gcc`, `postgresql-server-dev-MAJOR` |
| 2 | `pgmq` | `pgmq.go` | Clones, compiles and installs [PGMQ](https://github.com/pgmq/pgmq) v1.11.1 |
| 3 | `pgvector` | `pgvector.go` | Clones, compiles and installs [pgvector](https://github.com/pgvector/pgvector) v0.8.2 |
| 4 | `postgis` | `postgis.go` | Installs `postgresql-MAJOR-postgis-3` via apt |
| 5 | `postgres-contrib` | `postgrescontrib.go` | Installs `postgresql-MAJOR` (contrib) via apt |
| 6 | `build-deps-remove` | `builddeps_remove.go` | Removes build dependencies and cleans apt |

### Why this order?

1. **First** install build tools (needed to compile pgmq and pgvector from source).
2. **Then** compile and install extensions that require source builds (pgmq, pgvector).
3. **After that** install extensions via apt (postgis, contrib), which need `postgresql-server-dev-MAJOR` present.
4. **Finally** remove build tools to keep the final image lightweight.

---

## Supported PostgreSQL versions

Currently: **14, 15, 16, 17, 18** (and `latest`, which points to the newest).

All playgrounds use the range `>=14.0.0, <19.0.0`. To extend support (e.g., PG 19), just update the ranges.

---

## How to create a new playground

### 1. Create the extension file

In `extensions/`, create a file like `myextension.go`:

```go
package extensions

import (
    "postgres-extensor/instance"
    "postgres-extensor/plyd"
)

var myExtension = plyd.New("my-extension",
    plyd.NewHandlersList(
        plyd.NewHandler(">=14.0.0, <19.0.0", func(ins *instance.InstanceInfo) error {
            return plyd.Run("apt-get install -y postgresql-" + ins.PostgreSQL.Mayor + "-my-extension")
        }),
    ),
)
```

### 2. Register it in the correct order

Edit `extensions/extensions.go` and add it to the `Playgrounds` slice at the right position:

```go
var Playgrounds = []*plyd.Playground{
    buildDepsInstall,
    pgmq,
    pgvector,
    myExtension,        // <-- New
    postgis,
    postgresContrib,
    buildDepsRemove,
}
```

### 3. Verify installation

Your handler should verify the extension was installed:

```go
verification := "test -f $(pg_config --sharedir)/extension/my_extension.control"
```

### 4. Add test coverage

Edit `.docker/runtime-test.sql` to include the new extension.

### 5. Build and test

```sh
make build PG_VERSION=18
make runtime-test PG_VERSION=18
```

# Instalador de extensiones para PostgreSQL (imagen Docker derivada)

## Propósito

Este proyecto genera una imagen Docker derivada de `postgres` que ya incluye varias extensiones populares de PostgreSQL instaladas y listas para usar. La instalación de las extensiones se realiza durante el proceso de build mediante un binario escrito en Rust (`install-extensions`) que se compila en una etapa `builder` y se ejecuta dentro de la imagen base de PostgreSQL.

El objetivo principal es ahorrar tiempo y complejidad al desplegar contenedores PostgreSQL que necesiten extensiones comunes ya instaladas y correctamente compiladas para la versión de PostgreSQL seleccionada.

## Extensiones incluidas

- PostGIS — PostGIS 3 (PostgreSQL 16 / 17 / 18) — ver en `src/extensions/postgis.rs`
- pgvector — v0.8.1 (PostgreSQL 16 / 17 / 18) — ver en `src/extensions/pgvector.rs`
- pgmq — v1.7.0 (PostgreSQL 16 / 17 / 18) — ver en `src/extensions/pgmq.rs`

También se instala:

- `postgresql-contrib`

Durante el build se instalan temporalmente paquetes necesarios para compilar las extensiones (por ejemplo `build-essential`, `git`, `postgresql-server-dev-<major>`, `ca-certificates`). Estos paquetes se purgan al finalizar el proceso para reducir el tamaño final de la imagen.

## ¿Por qué he usado `Rust`?

He elegido `Rust` para el instalador porque necesitaba:

- Control total sobre qué versiones de cada extensión se instalan y cómo se instalan.
- Un binario autocontenible que pueda compilarse en la etapa `builder` y copiarse a la imagen final (`/usr/local/bin/installer`), para ejecutarlo y eliminarlo después (ver `Dockerfile`).
  Esto permite que la imagen final sea ligera y no incluya dependencias de compilación ni runtimes interpretados.

Ventajas concretas de `Rust` en este caso:

- Binario nativo y sin runtime adicional: reduce el tamaño de la imagen y la superficie de ataque frente a soluciones basadas en `Python` u otros lenguajes interpretados.
- Tipado estático y manejo de errores: facilita detectar y controlar condiciones de fallo durante la instalación en tiempo de compilación y en ejecución.
- Buenas herramientas para concurrencia: puedo usar crates como `tokio` para ejecutar instalaciones en paralelo de forma segura y eficiente.
- Reproducibilidad y empaquetado: con `cargo` y la compilación en `builder` stage la lógica queda encapsulada en un único ejecutable.

## ¿Como funciona el gestor de versiones?

```rust
static VERSIONS: LazyLock<ExtensionVersionCompatibility> =
    LazyLock::new(|| ExtensionVersionCompatibility {
        v16: "1.7.0",
        v17: "1.7.0",
        v18: "1.7.0",
    });
```

Esta estructura define la ultima version compatible con la version major de PostgreSQL. Esto permite que el instalador seleccione automáticamente la versión correcta de cada extensión según la versión de PostgreSQL en uso.

Por ejemplo, para `pgmq`, la versión `1.7.0` es compatible con PostgreSQL 16, 17 y 18. Si en el futuro se elimina el soporte en la version `1.8.0` para PostgreSQL 16, se mantendria la version `1.7.0` para PostgreSQL 16 y se podria definir una nueva version `1.8.0` para PostgreSQL 17 y 18.

Ademas, si se desea agregar soporte para una nueva version mayor de PostgreSQL (por ejemplo, PostgreSQL 19), solo se necesita actualizar esta estructura para incluir la nueva version compatible de cada extensión.

## ¿Como contribuir?
- Consulta `CONTRIBUTING.es.md` para las pautas de contribución en español.
- Para la versión en inglés, consulta `CONTRIBUTING.md`.
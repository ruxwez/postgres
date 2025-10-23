# PostgreSQL Extensions Installer (derived Docker image)
![Docker Pulls](https://img.shields.io/docker/pulls/ruxwez/postgres?style=flat-square)
![GitHub branch status](https://img.shields.io/github/checks-status/ruxwez/postgres/main?style=flat-square)
![GitHub contributors](https://img.shields.io/github/contributors/ruxwez/postgres?style=flat-square)
![GitHub License](https://img.shields.io/github/license/ruxwez/postgres?style=flat-square)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/ruxwez/postgres?style=flat-square)

## Purpose

This project builds a Docker image derived from the official `postgres` image that already includes several popular PostgreSQL extensions installed and ready to use. Extensions are installed during the image build using a Rust binary (`install-extensions`) that is compiled in a `builder` stage and executed inside the base PostgreSQL image.

The main goal is to save time and reduce complexity when deploying PostgreSQL containers that require common extensions preinstalled and compiled for the selected PostgreSQL version.

## Included extensions

- PostGIS — PostGIS 3 (PostgreSQL 16 / 17 / 18) — see `src/extensions/postgis.rs`
- pgvector — v0.8.1 (PostgreSQL 16 / 17 / 18) — see `src/extensions/pgvector.rs`
- pgmq — v1.7.0 (PostgreSQL 16 / 17 / 18) — see `src/extensions/pgmq.rs`

Also installed:

- `postgresql-contrib`

During the build, temporary packages required to compile the extensions are installed (for example `build-essential`, `git`, `postgresql-server-dev-<major>`, `ca-certificates`). These packages are removed at the end of the build process to reduce the final image size.

## Why Rust?

I chose `Rust` for the installer because I needed:

- Full control over which versions of each extension are installed and how they are installed.
- A self-contained binary that can be built in the `builder` stage and copied into the final image (`/usr/local/bin/installer`), executed, and then removed (see the `Dockerfile`). This keeps the final image slim and free of build dependencies or interpreted runtimes.

Concrete advantages of using `Rust` here:

- Native binary without an additional runtime: reduces image size and the attack surface compared to solutions based on `Python` or other interpreted languages.
- Static typing and robust error handling: helps catch and manage failure conditions both at compile time and runtime.
- Good concurrency tooling: crates like `tokio` can be used to run installations in parallel safely and efficiently.
- Reproducibility and packaging: with `cargo` and the `builder` stage, the installation logic is encapsulated in a single executable.

## How does the version manager work?

```/dev/null/versions.rs#L1-9
static VERSIONS: LazyLock<ExtensionVersionCompatibility> =
    LazyLock::new(|| ExtensionVersionCompatibility {
        v16: "1.7.0",
        v17: "1.7.0",
        v18: "1.7.0",
    });
```

This structure defines the latest compatible version for each PostgreSQL major version. It allows the installer to automatically select the correct version of each extension according to the PostgreSQL version in use.

For example, for `pgmq`, version `1.7.0` is compatible with PostgreSQL 16, 17, and 18. If in the future version `1.8.0` drops support for PostgreSQL 16, you would keep `1.7.0` mapped to PostgreSQL 16 and define `1.8.0` for PostgreSQL 17 and 18.

Also, if you want to add support for a new major PostgreSQL release (for example, PostgreSQL 19), you only need to update this structure to include the new compatible version for each extension.

## How to contribute

See `CONTRIBUTING.md` for detailed contribution guidelines: how to report bugs or feature requests (use the provided issue templates), the PR workflow, and step-by-step instructions to add a new PostgreSQL extension. A Spanish translation of the contributor guide is available at `CONTRIBUTING.es.md` and is referenced from `README.es.md`.

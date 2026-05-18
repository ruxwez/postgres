# Contributing

> [Leer en español](./CONTRIBUTING.es.md)

Thank you for your interest in contributing to PostgreSQL Extensor.

## Reporting issues

Use the templates in `.github/ISSUE_TEMPLATE/`:

- **Bug report** — for errors or unexpected behavior.
- **Feature request** — to suggest new extensions or features.
- **Custom** — for any other case.

## Pull Requests

1. Fork the repository.
2. Create a branch with a descriptive name: `feat/pg-partman`, `fix/pgvector-build`.
3. Make sure tests pass for all PostgreSQL versions:

   ```sh
   make test
   make runtime-test PG_VERSION=18
   ```

4. If adding a new extension, include:
   - The playground in `extensions/`.
   - The registration in `extensions/extensions.go`.
   - The verification in `.docker/runtime-test.sql`.
   - Update the relevant documentation in `.docs/`.

5. Open the PR against `main`. CI workflows will run tests automatically for all supported versions.

## Guidelines

- Follow the style of existing code.
- Don't add unnecessary dependencies to `go.mod`.
- Playgrounds should be idempotent and clean up temporary files.
- Document semver version ranges clearly.

## Project structure

```
.docker/          — Dockerfiles and test scripts
.docs/            — Documentation
.github/          — CI/CD workflows and templates
extensions/       — Playground definitions
instance/         — Environment detection (OS, PG version)
plyd/             — Playground engine (core framework)
utils/            — Semver versioning utilities
```

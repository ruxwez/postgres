# Contributing

> [Leer en español](./CONTRIBUTING.es.md)

Thank you for your interest in contributing to PostgreSQL Extensor.

## Reporting issues

Use the templates in `.github/ISSUE_TEMPLATE/`:

- **Bug report:** for errors or unexpected behavior.
- **Feature request:** to suggest new extensions or features.
- **Custom:** for anything else.

## Pull Requests

1. Fork the repository.
2. Create a branch with a descriptive name: `feat/pg-partman`, `fix/pgvector-build`.
3. Run the tests for at least one version locally:

   ```sh
   make test PG_VERSION=18
   ```

4. If you're adding an extension, follow [Extensions](./.docs/extensions.md). It comes down to a few lines in the `Dockerfile`, an `extensions/<name>/test.sql`, and a row in the README table.
5. Open the PR against `main`. CI builds and tests every version on amd64 and arm64.

Merging only updates the floating tags (`18`, `latest`). Maintainers cut releases to update the versioned tags (see [Releases](./.docs/releases.md)).

## Guidelines

- Prefer PGDG apt packages over building from source.
- Pin every extension version, apt packages included, using an `ARG` with a `# renovate:` comment.
- Build tools go in `build-base`, never in the final stage.

## Project structure

```
Dockerfile            Image definition (one stage per extension built from source)
docker-bake.hcl       PostgreSQL versions and tags
extensions/<name>/    test.sql for each extension
tests/run.sh          Runs every test.sql against an image
.github/workflows/    CI: build, test, publish, release
.github/scripts/      Helpers used by CI (release notes)
.docs/                Documentation
```

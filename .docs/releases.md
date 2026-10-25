# Releases

> [Leer en español](./releases.es.md)

## Tags

Every build publishes the floating tags. A release also publishes the versioned ones:

| Tag | Published by | Changes? |
|-----|--------------|----------|
| `18-v1.4.0` | release `v1.4.0` | Never. CI refuses to publish a release that already exists. |
| `18-v1` | every `v1.x.y` release | Moves to the newest `v1` release. |
| `18`, `latest` | every build (push to `main`, weekly, release) | Always the latest build. |

The weekly rebuild (security fixes in the base image) only moves `18` and `latest`. Versioned tags change only when you cut a release.

## Versioning

The version describes **what the image contains**, following semver from the user's point of view:

| Bump | When | Examples |
|------|------|----------|
| **patch** `v1.4.0 → v1.4.1` | Same extension versions, rebuilt or fixed | Ship the base image's security fixes or a new PostgreSQL minor to `18-v1`; fix something in the build |
| **minor** `v1.4.x → v1.5.0` | Compatible changes | An extension gets a compatible update (pgvector 0.8.2 → 0.8.7); a new extension is added; a new PostgreSQL major is added |
| **major** `v1.x.y → v2.0.0` | Something can break | An extension gets a major update (pgmq 1.x → 2.x); an extension or a PostgreSQL major is removed |

If you're unsure whether an upgrade is compatible, read the extension's changelog. When in doubt, bump the major: a `-v1` user should never be broken by an update.

## Publishing a release

From an up-to-date `main`:

```sh
git tag v1.4.0
git push origin v1.4.0
```

Or create the release from the GitHub UI with a new tag. CI then:

1. Checks the tag looks like `vX.Y.Z` and is the **newest** release tag. Releasing an older version after a newer one would move `18-v1` and `latest` backwards.
2. Checks that none of the `<pg>-vX.Y.Z` tags exist on Docker Hub yet.
3. Builds and tests every PostgreSQL version on both architectures. Nothing is published if any fails.
4. Publishes `<pg>-vX.Y.Z`, `<pg>-vX`, `<pg>` and `latest`.
5. Creates the GitHub release with the automatic changelog and a table of the exact versions in each image. If you wrote release notes yourself, the table is appended to them.

If a publish job fails halfway (e.g. a Docker Hub error), use **Re-run failed jobs**. A full re-run would stop at step 2, because some tags already exist.

## Labels

Every image carries its versions as labels:

```sh
docker inspect ruxwez/postgres:18-v1 --format '{{json .Config.Labels}}'
```

| Label | Value |
|-------|-------|
| `org.opencontainers.image.version` | project release (`1.4.0`), empty outside releases |
| `org.opencontainers.image.revision` | git commit |
| `io.github.ruxwez.postgres.postgresql.version` | PostgreSQL package version |
| `io.github.ruxwez.postgres.<extension>.version` | version of each extension (pgvector, pgmq, postgis) |

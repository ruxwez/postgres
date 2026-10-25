# Extensions

> [Leer en español](./extensions.es.md)

Every extension has two parts:

1. **How it's installed**, in the [`Dockerfile`](../Dockerfile).
2. **How it's tested**, in `extensions/<name>/test.sql`.

There is no other code to touch.

## Adding an extension

### Option A: it's packaged in PGDG (preferred)

Look for `postgresql-<major>-<name>` on [apt.postgresql.org](https://apt.postgresql.org/pub/repos/apt/pool/main/). It has to exist for every supported version.

Declare its version at the top of the Dockerfile. The `# renovate:` comment points Renovate at the PGDG index, so it opens a PR when a new version is packaged:

```dockerfile
# renovate: datasource=deb depName=postgresql-18-my-extension registryUrl=https://apt.postgresql.org/pub/repos/apt?suite=trixie-pgdg&components=main&binaryArch=amd64
ARG MY_EXTENSION_VERSION=1.2.3
```

`suite` is the Debian release of the base image (`trixie` today) followed by `-pgdg`. Check it with `docker run --rm postgres:18 cat /etc/os-release`.

Then add it to the `apt-get install` in the final stage, pinned, and to the labels:

```dockerfile
ARG MY_EXTENSION_VERSION
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      "postgresql-${PG_MAJOR}-postgis-3=${POSTGIS_VERSION}+*" \
      "postgresql-${PG_MAJOR}-my-extension=${MY_EXTENSION_VERSION}*" \
 && rm -rf /var/lib/apt/lists/*
LABEL ... \
      io.github.ruxwez.postgres.my-extension.version="${MY_EXTENSION_VERSION}"
```

The trailing `*` matches the Debian revision (`1.2.3-1.pgdg13+1`). Use `+*` when the package version contains `+dfsg` or similar, as PostGIS does. You can list the available versions with:

```sh
docker run --rm postgres:18 bash -c 'apt-get update -qq && apt-cache madison postgresql-18-my-extension'
```

PGDG usually keeps a few previous versions in its index, so the pin keeps working for a while after a new release. Once a version is dropped from the index, the build fails with `Version '…' was not found` until the Renovate PR is merged.

`PG_MAJOR` is set by the official base image.

### Option B: build it from source

Declare its version at the top of the Dockerfile, next to the others:

```dockerfile
# renovate: datasource=github-tags depName=owner/my-extension
ARG MY_EXTENSION_VERSION=1.2.3
```

The `# renovate:` comment right above the `ARG` lets Renovate open a PR whenever a new tag is released. Keep the same format.

Add a stage on top of `build-base`. It must install into `/out` (via `DESTDIR`):

```dockerfile
FROM build-base AS my-extension
ARG MY_EXTENSION_VERSION
RUN git clone --depth 1 --branch "v${MY_EXTENSION_VERSION}" https://github.com/owner/my-extension.git /src \
 && make -C /src \
 && make -C /src install DESTDIR=/out
```

In the final stage, copy it over and add its version to the labels:

```dockerfile
ARG MY_EXTENSION_VERSION
COPY --from=my-extension /out/ /
LABEL ... \
      io.github.ruxwez.postgres.my-extension.version="${MY_EXTENSION_VERSION}"
```

If the build needs extra packages, add them to `build-base`. They won't reach the final image.

### Then, in both cases

Create `extensions/<name>/test.sql`. It should **use** the extension, not only create it, and raise an error if the result is wrong:

```sql
CREATE EXTENSION my_extension;

DO $$
BEGIN
  IF my_function(1) <> 2 THEN
    RAISE EXCEPTION 'my_extension: unexpected result';
  END IF;
END $$;
```

`tests/run.sh` picks it up automatically. Finally, add the extension to the table in the README.

## Upgrading an extension

Change its `ARG *_VERSION` at the top of the Dockerfile. Renovate opens these PRs for you, for both apt packages and extensions built from source.

Once merged, the change only reaches `18` and `latest`. To ship it to `18-v1`, cut a release (see [Releases](./releases.md) to pick the version bump).

## Adding or dropping a PostgreSQL version

Edit the `major` list in [`docker-bake.hcl`](../docker-bake.hcl). To move `:latest` to a new major, change `LATEST` too. CI builds and tests every version in that list, so a version where some extension isn't available fails the build.

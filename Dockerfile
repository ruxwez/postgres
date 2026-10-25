# syntax=docker/dockerfile:1

# Builds one image: postgres:<POSTGRES_VERSION> plus the extensions below.
# The list of versions/tags lives in docker-bake.hcl.

ARG POSTGRES_VERSION=18

# Extension versions. Renovate bumps them using the comment right above each
# one.
# renovate: datasource=github-tags depName=pgvector/pgvector
ARG PGVECTOR_VERSION=0.8.2
# renovate: datasource=github-tags depName=pgmq/pgmq
ARG PGMQ_VERSION=1.11.1
# PGDG package, same version for every PostgreSQL major. PGDG keeps a few
# previous versions in its index, so the pin keeps working for a while after a
# new one comes out.
# renovate: datasource=deb depName=postgresql-18-postgis-3 registryUrl=https://apt.postgresql.org/pub/repos/apt?suite=trixie-pgdg&components=main&binaryArch=amd64
ARG POSTGIS_VERSION=3.6.4

# ---------------------------------------------------------------------------
# Toolchain for extensions compiled from source. Nothing from this stage ends
# up in the final image: each extension stage installs into /out and only that
# directory is copied over.
# ---------------------------------------------------------------------------
FROM postgres:${POSTGRES_VERSION} AS build-base
RUN apt-get update \
 && apt-get install -y ca-certificates git make gcc "postgresql-server-dev-${PG_MAJOR}"

FROM build-base AS pgvector
ARG PGVECTOR_VERSION
# OPTFLAGS="" avoids -march=native, so the binary runs on any CPU and not just
# the one that built it.
RUN git clone --depth 1 --branch "v${PGVECTOR_VERSION}" https://github.com/pgvector/pgvector.git /src \
 && make -C /src OPTFLAGS="" \
 && make -C /src install OPTFLAGS="" DESTDIR=/out

FROM build-base AS pgmq
ARG PGMQ_VERSION
RUN git clone --depth 1 --branch "v${PGMQ_VERSION}" https://github.com/pgmq/pgmq.git /src \
 && make -C /src/pgmq-extension \
 && make -C /src/pgmq-extension install DESTDIR=/out

# ---------------------------------------------------------------------------
# Final image
# ---------------------------------------------------------------------------
FROM postgres:${POSTGRES_VERSION}
ARG PGVECTOR_VERSION
ARG PGMQ_VERSION
ARG POSTGIS_VERSION

# Extensions available as PGDG packages. contrib (pg_stat_statements,
# pg_trgm, ...) already ships with the base image. "+*" matches any Debian
# revision of the pinned upstream version (3.6.4+dfsg-2.pgdg13+1, ...).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      "postgresql-${PG_MAJOR}-postgis-3=${POSTGIS_VERSION}+*" \
 && rm -rf /var/lib/apt/lists/*

COPY --from=pgvector /out/ /
COPY --from=pgmq /out/ /

# What's inside, readable with `docker inspect` without starting the image.
# PG_VERSION is the Debian package version set by the base image.
LABEL io.github.ruxwez.postgres.postgresql.version="${PG_VERSION}" \
      io.github.ruxwez.postgres.pgvector.version="${PGVECTOR_VERSION}" \
      io.github.ruxwez.postgres.pgmq.version="${PGMQ_VERSION}" \
      io.github.ruxwez.postgres.postgis.version="${POSTGIS_VERSION}"

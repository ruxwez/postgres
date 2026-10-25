# syntax=docker/dockerfile:1

# Builds one image: postgres:<POSTGRES_VERSION> plus the extensions below.
# The list of versions/tags lives in docker-bake.hcl.
#
# Extensions come from four places, in order of preference:
#   1. PGDG apt packages, listed in extensions/pgdg.txt.
#   2. Prebuilt packages published by the extension's authors.
#   3. Files copied from the authors' official Docker image.
#   4. Built from source, for anything else.
# Build tools never reach the final image: stages 2-4 install into /out and
# only that directory is copied over.

ARG POSTGRES_VERSION=18

# Versions of the extensions that don't come from PGDG. Renovate bumps them
# using the comment right above each one.

# renovate: datasource=github-tags depName=pgmq/pgmq
ARG PGMQ_VERSION=1.11.1
# renovate: datasource=github-tags depName=pgbigm/pg_bigm
ARG PG_BIGM_VERSION=1.2-20250903
# renovate: datasource=github-tags depName=iCyberon/pg_hashids
ARG PG_HASHIDS_VERSION=1.2.1
# renovate: datasource=github-tags depName=CrunchyData/pg_incremental
ARG PG_INCREMENTAL_VERSION=1.5.0
# renovate: datasource=github-tags depName=supabase/pg_net
ARG PG_NET_VERSION=0.20.5
# renovate: datasource=github-tags depName=percona/pg_stat_monitor
ARG PG_STAT_MONITOR_VERSION=2.4.0
# renovate: datasource=github-tags depName=michelp/pgsodium
ARG PGSODIUM_VERSION=3.1.11
# renovate: datasource=github-tags depName=mpartel/postgres-protobuf
ARG POSTGRES_PROTOBUF_VERSION=0.3.3
# renovate: datasource=github-tags depName=arkhipov/temporal_tables
ARG TEMPORAL_TABLES_VERSION=1.2.2
# No tagged releases upstream; pinned to its latest commit (2023).
ARG PGJWT_COMMIT=f3d82fd30151e754e19ce5d6a06c71c20689ce3d

# renovate: datasource=gitlab-releases depName=dalibo/postgresql_anonymizer
ARG ANON_VERSION=3.2.3
# renovate: datasource=github-releases depName=supabase/pg_graphql
ARG PG_GRAPHQL_VERSION=1.6.2
# renovate: datasource=github-releases depName=supabase/pg_jsonschema
ARG PG_JSONSCHEMA_VERSION=0.3.4
# renovate: datasource=github-releases depName=timescale/pgvectorscale
ARG PGVECTORSCALE_VERSION=0.9.1
# renovate: datasource=github-releases depName=supabase/wrappers
ARG WRAPPERS_VERSION=0.6.4

# renovate: datasource=github-releases depName=duckdb/pg_duckdb
ARG PG_DUCKDB_VERSION=1.1.1
# renovate: datasource=github-releases depName=ClickHouse/pg_clickhouse
ARG PG_CLICKHOUSE_VERSION=0.11.0

# ---------------------------------------------------------------------------
# Toolchain shared by the stages below.
# ---------------------------------------------------------------------------
FROM postgres:${POSTGRES_VERSION} AS build-base
RUN apt-get update \
 && apt-get install -y ca-certificates curl git make gcc g++ unzip \
      "postgresql-server-dev-${PG_MAJOR}"
COPY extensions/pgxs-build.sh /usr/local/bin/pgxs-build
COPY extensions/fetch-deb.sh /usr/local/bin/fetch-deb

# ---------------------------------------------------------------------------
# Prebuilt packages from the extensions' releases.
# ---------------------------------------------------------------------------
FROM build-base AS prebuilt
ARG TARGETARCH
ARG ANON_VERSION
ARG PG_GRAPHQL_VERSION
ARG PG_JSONSCHEMA_VERSION
ARG PGVECTORSCALE_VERSION
ARG WRAPPERS_VERSION
RUN fetch-deb "https://gitlab.com/api/v4/projects/dalibo%2Fpostgresql_anonymizer/packages/generic/release-assets/${ANON_VERSION}/postgresql_anonymizer_${PG_MAJOR}_${ANON_VERSION}_${TARGETARCH}.deb" \
 && fetch-deb "https://github.com/supabase/pg_graphql/releases/download/v${PG_GRAPHQL_VERSION}/pg_graphql-v${PG_GRAPHQL_VERSION}-pg${PG_MAJOR}-${TARGETARCH}-linux-gnu.deb" \
 && fetch-deb "https://github.com/supabase/pg_jsonschema/releases/download/v${PG_JSONSCHEMA_VERSION}/pg_jsonschema-v${PG_JSONSCHEMA_VERSION}-pg${PG_MAJOR}-${TARGETARCH}-linux-gnu.deb" \
 && fetch-deb "https://github.com/timescale/pgvectorscale/releases/download/${PGVECTORSCALE_VERSION}/pgvectorscale-${PGVECTORSCALE_VERSION}-pg${PG_MAJOR}-${TARGETARCH}.zip" \
 && fetch-deb "https://github.com/supabase/wrappers/releases/download/v${WRAPPERS_VERSION}/wrappers-v${WRAPPERS_VERSION}-pg${PG_MAJOR}-${TARGETARCH}-linux-gnu.deb"

# ---------------------------------------------------------------------------
# Files copied from the extensions' official images, which ship the only
# prebuilt binaries (both bundle large C++ engines).
# ---------------------------------------------------------------------------
FROM pgduckdb/pgduckdb:${POSTGRES_VERSION}-v${PG_DUCKDB_VERSION} AS pg-duckdb-upstream
USER root
RUN mkdir -p /out/usr/lib/postgresql/$PG_MAJOR/lib /out/usr/share/postgresql/$PG_MAJOR/extension \
 && cp -a /usr/lib/postgresql/$PG_MAJOR/lib/pg_duckdb.so /usr/lib/postgresql/$PG_MAJOR/lib/libduckdb.so \
      /out/usr/lib/postgresql/$PG_MAJOR/lib/ \
 && cp -a /usr/share/postgresql/$PG_MAJOR/extension/pg_duckdb* /out/usr/share/postgresql/$PG_MAJOR/extension/

# Also provides re2 (ClickHouse/pg_re2), its companion for regex pushdown.
FROM ghcr.io/clickhouse/pg_clickhouse:${POSTGRES_VERSION}-${PG_CLICKHOUSE_VERSION} AS pg-clickhouse-upstream
USER root
RUN mkdir -p /out/usr/lib/postgresql/$PG_MAJOR/lib /out/usr/share/postgresql/$PG_MAJOR/extension \
 && cp -a /usr/lib/postgresql/$PG_MAJOR/lib/pg_clickhouse.so /usr/lib/postgresql/$PG_MAJOR/lib/re2.so \
      /out/usr/lib/postgresql/$PG_MAJOR/lib/ \
 && cp -a /usr/share/postgresql/$PG_MAJOR/extension/pg_clickhouse* /usr/share/postgresql/$PG_MAJOR/extension/re2* \
      /out/usr/share/postgresql/$PG_MAJOR/extension/

# ---------------------------------------------------------------------------
# Built from source.
# ---------------------------------------------------------------------------
FROM build-base AS source
RUN apt-get install -y libcurl4-openssl-dev libicu-dev cmake zlib1g-dev ruby
# pgsodium needs libsodium 1.0.21+, newer than Debian's. Built as a static
# library so pgsodium carries it and the final image needs nothing extra.
# Bump it together with pgsodium.
ARG LIBSODIUM_VERSION=1.0.22
RUN curl -fsSL --retry 5 --retry-all-errors \
      "https://github.com/jedisct1/libsodium/releases/download/${LIBSODIUM_VERSION}-RELEASE/libsodium-${LIBSODIUM_VERSION}.tar.gz" \
    | tar xz -C /tmp \
 && cd "/tmp/libsodium-${LIBSODIUM_VERSION}" \
 && ./configure --prefix=/usr/local --disable-shared --with-pic \
 && make -j"$(nproc)" install
ARG PGMQ_VERSION
ARG PG_BIGM_VERSION
ARG PG_HASHIDS_VERSION
ARG PG_INCREMENTAL_VERSION
ARG PG_NET_VERSION
ARG PG_STAT_MONITOR_VERSION
ARG PGSODIUM_VERSION
ARG POSTGRES_PROTOBUF_VERSION
ARG TEMPORAL_TABLES_VERSION
ARG PGJWT_COMMIT
RUN pgxs-build https://github.com/pgmq/pgmq.git "v${PGMQ_VERSION}" pgmq-extension
RUN pgxs-build https://github.com/pgbigm/pg_bigm.git "v${PG_BIGM_VERSION}" . USE_PGXS=1
RUN pgxs-build https://github.com/iCyberon/pg_hashids.git "v${PG_HASHIDS_VERSION}"
RUN MIN_PG_MAJOR=15 pgxs-build https://github.com/CrunchyData/pg_incremental.git "v${PG_INCREMENTAL_VERSION}"
RUN pgxs-build https://github.com/supabase/pg_net.git "v${PG_NET_VERSION}"
RUN pgxs-build https://github.com/percona/pg_stat_monitor.git "${PG_STAT_MONITOR_VERSION}" . USE_PGXS=1
RUN pgxs-build https://github.com/michelp/pgsodium.git "v${PGSODIUM_VERSION}"
RUN pgxs-build https://github.com/arkhipov/temporal_tables.git "v${TEMPORAL_TABLES_VERSION}"
RUN pgxs-build https://github.com/michelp/pgjwt.git "${PGJWT_COMMIT}"
# Links a static protobuf library that its own script downloads and builds.
RUN git clone --depth 1 --branch "v${POSTGRES_PROTOBUF_VERSION}" --recurse-submodules --shallow-submodules \
      https://github.com/mpartel/postgres-protobuf.git /tmp/postgres-protobuf \
 && cd /tmp/postgres-protobuf \
 && ./build-protobuf-library.sh \
 && make -j"$(nproc)" \
 && make install DESTDIR=/out

# ---------------------------------------------------------------------------
# Final image
# ---------------------------------------------------------------------------
FROM postgres:${POSTGRES_VERSION}

# PGDG packages from extensions/pgdg.txt (the lines for this major), plus the
# runtime libraries of the extensions copied in below. contrib
# (pg_stat_statements, pg_trgm, ...) already ships with the base image.
RUN --mount=type=bind,source=extensions/pgdg.txt,target=/tmp/pgdg.txt \
    set -eu; \
    packages="$(awk -v major="$PG_MAJOR" ' \
      /^[[:space:]]*(#|$)/ { next } \
      { split($1, name, "/"); if (name[2] != "" && name[2] != major) next; \
        printf "postgresql-%s-%s=%s* ", major, name[1], $2 }' /tmp/pgdg.txt)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends $packages \
      libcurl4t64 liblz4-1 libre2-11 libxxhash0; \
    rm -rf /var/lib/apt/lists/*

COPY --from=prebuilt /out/ /
COPY --from=pg-duckdb-upstream /out/ /
COPY --from=pg-clickhouse-upstream /out/ /
COPY --from=source /out/ /

# Every extension and its version, readable without starting PostgreSQL:
#   docker run --rm ruxwez/postgres:18 cat /usr/share/postgres-extensor/extensions.txt
RUN --mount=type=bind,source=extensions/list-extensions.sh,target=/tmp/list-extensions.sh \
    mkdir -p /usr/share/postgres-extensor \
 && /tmp/list-extensions.sh > /usr/share/postgres-extensor/extensions.txt

# PG_VERSION is the Debian package version set by the base image.
LABEL io.github.ruxwez.postgres.postgresql.version="${PG_VERSION}"

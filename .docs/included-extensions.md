# Included extensions

> [Leer en español](./included-extensions.es.md)

Every image includes the extensions below, plus all of [contrib](https://www.postgresql.org/docs/current/contrib.html) (`pg_stat_statements`, `pg_trgm`, `pgcrypto`, `hstore`, …), which ships with PostgreSQL.

The exact version of each one, for every PostgreSQL major, is in the [release notes](https://github.com/ruxwez/postgres/releases). Inside an image:

```sh
docker run --rm ruxwez/postgres:18-v1 cat /usr/share/postgres-extensor/extensions.txt
```

## Using them

Nothing is enabled by default, so the image behaves exactly like the official one. Enable what you need with `CREATE EXTENSION <name>` in each database.

Extensions marked **preload** also have to be added to `shared_preload_libraries`, which requires a restart:

```yaml
services:
  db:
    image: ruxwez/postgres:18-v1
    command: postgres -c shared_preload_libraries=pg_cron,timescaledb -c cron.database_name=postgres
```

Some caveats:

- **pg_show_plans and timescaledb can't be preloaded together.** Inserting into a hypertable crashes the server (segfault). Preload one or the other.
- **Many preloaded extensions start background workers.** If you preload several, raise `max_worker_processes` (the default is 8).
- **wal2json** needs `wal_level = logical`. Recent minor releases also require `output_plugin_libraries = 'wal2json'`.
- **pg_cron** and the extensions built on it (`pg_incremental`, `documentdb`) only work in the database named by `cron.database_name` (`postgres` by default).

## By category

The **Source** column says how each extension gets into the image:

- **PGDG**: package from [apt.postgresql.org](https://apt.postgresql.org).
- **Release**: the authors' prebuilt package.
- **Image**: copied from the authors' official image.
- **Source**: built from source.

### AI and vectors

| Extension | Description | Source | Notes |
|---|---|---|---|
| `vector` | [pgvector](https://github.com/pgvector/pgvector): vector similarity search | PGDG | |
| `vectorscale` | [pgvectorscale](https://github.com/timescale/pgvectorscale): DiskANN index for pgvector | Release | |

### Geospatial

| Extension | Description | Source | Notes |
|---|---|---|---|
| `postgis` (+ `postgis_raster`, `postgis_topology`, `postgis_sfcgal`, `postgis_tiger_geocoder`) | [PostGIS](https://postgis.net/): geometry and geography types | PGDG | |
| `pgrouting` | [pgRouting](https://pgrouting.org/): routing and network analysis on PostGIS | PGDG | |
| `h3`, `h3_postgis` | [h3-pg](https://github.com/postgis/h3-pg): Uber's H3 hexagonal grid | PGDG | |
| `pg_sphere` | [pgSphere](https://github.com/postgrespro/pgsphere): spherical geometry | PGDG | |

### Search and text

| Extension | Description | Source | Notes |
|---|---|---|---|
| `pg_textsearch` | [pg_textsearch](https://github.com/timescale/pg_textsearch): BM25-ranked full-text search | PGDG | preload; PG 17+ |
| `rum` | [RUM](https://github.com/postgrespro/rum): GIN-like index with ranking | PGDG | |
| `pg_bigm` | [pg_bigm](https://github.com/pgbigm/pg_bigm): 2-gram full-text search, good for CJK | Source | |
| `pg_similarity` | [pg_similarity](https://github.com/eulerto/pg_similarity): string similarity (Levenshtein, Jaro, cosine…) | PGDG | |
| `pgpcre` | [pgpcre](https://github.com/petere/pgpcre): Perl-compatible regular expressions | PGDG | |
| `re2` | [pg_re2](https://github.com/ClickHouse/pg_re2): RE2 regular expressions | Image | |
| `icu_ext` | [icu_ext](https://github.com/dverite/icu_ext): ICU functions (transliteration, spell-out…) | PGDG | |

### Time series and analytics

| Extension | Description | Source | Notes |
|---|---|---|---|
| `timescaledb` | [TimescaleDB](https://github.com/timescale/timescaledb): hypertables and time-series functions (Apache-2.0 edition) | PGDG | preload |
| `pg_duckdb` | [pg_duckdb](https://github.com/duckdb/pg_duckdb): DuckDB analytics engine inside PostgreSQL | Image | preload |
| `pg_ivm` | [pg_ivm](https://github.com/sraoss/pg_ivm): incrementally maintained materialized views | PGDG | |
| `pg_incremental` | [pg_incremental](https://github.com/CrunchyData/pg_incremental): incremental batch pipelines | Source | needs pg_cron; PG 15+ |
| `hll` | [postgresql-hll](https://github.com/citusdata/postgresql-hll): HyperLogLog distinct counts | PGDG | |
| `tdigest` | [tdigest](https://github.com/tvondra/tdigest): percentile estimation | PGDG | |
| `roaringbitmap` | [pg_roaringbitmap](https://github.com/ChenHuajun/pg_roaringbitmap): compressed bitmaps | PGDG | |
| `first_last_agg` | [first_last_agg](https://github.com/wulczer/first_last_agg): `first()` and `last()` aggregates | PGDG | |
| `extra_window_functions` | [extra_window_functions](https://github.com/xocolatl/extra_window_functions): more window functions | PGDG | |

### Queues, jobs and background work

| Extension | Description | Source | Notes |
|---|---|---|---|
| `pgmq` | [PGMQ](https://github.com/pgmq/pgmq): message queues | Source | |
| `pg_cron` | [pg_cron](https://github.com/citusdata/pg_cron): cron-style job scheduler | PGDG | preload |
| `pg_background` | [pg_background](https://github.com/vibhorkum/pg_background): run SQL in background workers | PGDG | |
| `pg_partman` | [pg_partman](https://github.com/pgpartman/pg_partman): automatic partition management | PGDG | preload for its background worker (optional) |

### JSON, documents and APIs

| Extension | Description | Source | Notes |
|---|---|---|---|
| `documentdb` | [DocumentDB](https://github.com/documentdb/documentdb): MongoDB-compatible document engine | PGDG | preload; needs pg_cron; PG 15+ |
| `pg_graphql` | [pg_graphql](https://github.com/supabase/pg_graphql): GraphQL API over your tables | Release | |
| `pg_jsonschema` | [pg_jsonschema](https://github.com/supabase/pg_jsonschema): JSON Schema validation | Release | |
| `jsquery` | [jsquery](https://github.com/postgrespro/jsquery): JSON query language | PGDG | |
| `http` | [pgsql-http](https://github.com/pramsey/pgsql-http): synchronous HTTP client | PGDG | |
| `pg_net` | [pg_net](https://github.com/supabase/pg_net): asynchronous HTTP requests | Source | preload |
| `pgjwt` | [pgjwt](https://github.com/michelp/pgjwt): JSON Web Tokens | Source | |
| `postgres_protobuf` | [postgres-protobuf](https://github.com/mpartel/postgres-protobuf): query Protocol Buffers | Source | |
| `pg_csv` | [pg_csv](https://github.com/PostgREST/pg_csv): CSV output | PGDG | |

### Data types

| Extension | Description | Source | Notes |
|---|---|---|---|
| `age` | [Apache AGE](https://github.com/apache/age): graph database with openCypher | PGDG | |
| `pg_uuidv7` | [pg_uuidv7](https://github.com/fboulnois/pg_uuidv7): time-ordered UUIDv7 | PGDG | |
| `pg_hashids` | [pg_hashids](https://github.com/iCyberon/pg_hashids): short IDs from integers | Source | |
| `ip4r` | [ip4r](https://github.com/RhodiumToad/ip4r): IPv4/IPv6 ranges | PGDG | |
| `prefix` | [prefix](https://github.com/dimitri/prefix): prefix ranges (phone routing…) | PGDG | |
| `semver` | [semver](https://github.com/theory/pg-semver): semantic versions | PGDG | |
| `pg_rational` | [pg_rational](https://github.com/begriffs/pg_rational): exact fractions | PGDG | |
| `timestamp9` | [timestamp9](https://github.com/optiver/timestamp9): nanosecond timestamps | PGDG | |
| `pg_rrule` | [pg_rrule](https://github.com/petropavel13/pg_rrule): iCalendar recurrence rules | PGDG | |
| `periods` | [periods](https://github.com/xocolatl/periods): SQL:2016 periods and system versioning | PGDG | |
| `temporal_tables` | [temporal_tables](https://github.com/arkhipov/temporal_tables): system-period temporal tables | Source | |

### Replication and CDC

| Extension | Description | Source | Notes |
|---|---|---|---|
| `pglogical` | [pglogical](https://github.com/2ndQuadrant/pglogical): logical replication | PGDG | preload; `wal_level = logical` |
| `wal2json` | [wal2json](https://github.com/eulerto/wal2json): JSON output plugin for logical decoding | PGDG | output plugin, see caveats |
| `pg_failover_slots` | [pg_failover_slots](https://github.com/EnterpriseDB/pg_failover_slots): logical slots that survive failover | PGDG | preload; not a `CREATE EXTENSION` |

### Monitoring and performance

| Extension | Description | Source | Notes |
|---|---|---|---|
| `pg_stat_monitor` | [pg_stat_monitor](https://github.com/percona/pg_stat_monitor): query statistics with histograms | Source | preload |
| `pg_stat_kcache` | [pg_stat_kcache](https://github.com/powa-team/pg_stat_kcache): per-query CPU and I/O | PGDG | preload, after `pg_stat_statements` |
| `pg_qualstats` | [pg_qualstats](https://github.com/powa-team/pg_qualstats): predicate statistics | PGDG | preload |
| `pg_wait_sampling` | [pg_wait_sampling](https://github.com/postgrespro/pg_wait_sampling): wait event sampling | PGDG | preload |
| `pg_show_plans` | [pg_show_plans](https://github.com/cybertec-postgresql/pg_show_plans): plans of running queries | PGDG | preload; not with timescaledb |
| `pg_statviz` | [pg_statviz](https://github.com/vyruss/pg_statviz): statistics snapshots | PGDG | |
| `hypopg` | [HypoPG](https://github.com/HypoPG/hypopg): hypothetical indexes | PGDG | |
| `pg_hint_plan` | [pg_hint_plan](https://github.com/ossc-db/pg_hint_plan): planner hints in comments | PGDG | preload |
| `pgfincore` | [pgfincore](https://github.com/klando/pgfincore): OS page cache inspection | PGDG | |
| `pgnodemx` | [pgnodemx](https://github.com/CrunchyData/pgnodemx): OS and cgroup metrics | PGDG | preload |
| `prioritize` | [prioritize](https://github.com/schmiddy/pg_prioritize): backend CPU priority | PGDG | |
| `toastinfo` | [toastinfo](https://github.com/credativ/toastinfo): how values are stored | PGDG | |
| `pg_dirtyread` | [pg_dirtyread](https://github.com/df7cb/pg_dirtyread): read deleted rows | PGDG | |
| `pg_repack` | [pg_repack](https://github.com/reorg/pg_repack): online table reorganization | PGDG | |
| `pg_squeeze` | [pg_squeeze](https://github.com/cybertec-postgresql/pg_squeeze): reclaim space without heavy locks | PGDG | preload; `wal_level = logical` |

### Security and auditing

| Extension | Description | Source | Notes |
|---|---|---|---|
| `pgaudit` | [pgAudit](https://github.com/pgaudit/pgaudit): audit logging | PGDG | preload |
| `anon` | [PostgreSQL Anonymizer](https://gitlab.com/dalibo/postgresql_anonymizer): data masking | Release | preload |
| `pgsodium` | [pgsodium](https://github.com/michelp/pgsodium): libsodium cryptography | Source | |
| `pg_pwhash` | [pg_pwhash](https://github.com/cybertec-postgresql/pg_pwhash): scrypt, yescrypt and argon2 password hashing | PGDG | |
| `credcheck` | [credcheck](https://github.com/HexaCluster/credcheck): password and user name policies | PGDG | preload |
| `set_user` | [set_user](https://github.com/pgaudit/set_user): audited role switching | PGDG | preload |
| `pg_permissions` | [pg_permissions](https://github.com/cybertec-postgresql/pg_permissions): review all permissions | PGDG | |

### Foreign data

| Extension | Description | Source | Notes |
|---|---|---|---|
| `wrappers` | [Wrappers](https://github.com/supabase/wrappers): foreign data wrappers for Stripe, S3, BigQuery… | Release | |
| `pg_clickhouse` | [pg_clickhouse](https://github.com/ClickHouse/pg_clickhouse): query ClickHouse | Image | |
| `tds_fdw` | [tds_fdw](https://github.com/tds-fdw/tds_fdw): query SQL Server and Sybase | PGDG | |

### Development and testing

| Extension | Description | Source | Notes |
|---|---|---|---|
| `pgtap` | [pgTAP](https://pgtap.org/): unit tests in SQL | PGDG | |
| `plpgsql_check` | [plpgsql_check](https://github.com/okbob/plpgsql_check): PL/pgSQL linter | PGDG | |
| `plprofiler` | [plprofiler](https://github.com/bigsql/plprofiler): PL/pgSQL profiler | PGDG | preload |
| `pljs` | [PLJS](https://github.com/plv8/pljs): JavaScript procedural language (QuickJS) | PGDG | |

### Compatibility

| Extension | Description | Source | Notes |
|---|---|---|---|
| `orafce` | [Orafce](https://github.com/orafce/orafce): Oracle functions and packages | PGDG | |
| `pgtt` | [pgtt](https://github.com/darold/pgtt): Oracle-style global temporary tables | PGDG | `LOAD 'pgtt'` per session |
| `db2fce` | [db2fce](https://github.com/credativ/db2fce): DB2 functions | PGDG | |

## Not included

These extensions were evaluated but aren't in the image:

| Extension | Why |
|---|---|
| [plv8](https://github.com/plv8/plv8) | Needs V8 compiled from source for every architecture: hours of build time and gigabytes of build cache per image. `pljs` (JavaScript on QuickJS) is included instead. |
| [pg_lake](https://github.com/Snowflake-Labs/pg_lake) | Bundles its own DuckDB, which conflicts with `pg_duckdb` in the same server, and needs a heavy C++/vcpkg toolchain. |
| [pg_durable](https://github.com/microsoft/pg_durable) | Only published for PostgreSQL 17–18 on amd64; arm64 and older majors would need a Rust (pgrx) build. |

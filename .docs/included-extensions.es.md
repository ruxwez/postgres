# Extensiones incluidas

> [Read in English](./included-extensions.md)

Todas las imágenes incluyen las extensiones de abajo, más todo [contrib](https://www.postgresql.org/docs/current/contrib.html) (`pg_stat_statements`, `pg_trgm`, `pgcrypto`, `hstore`, …), que viene con PostgreSQL.

La versión exacta de cada una, para cada versión mayor de PostgreSQL, está en las [release notes](https://github.com/ruxwez/postgres/releases). Dentro de una imagen:

```sh
docker run --rm ruxwez/postgres:18-v1 cat /usr/share/postgres-extensor/extensions.txt
```

## Cómo usarlas

No hay nada activado por defecto, así que la imagen se comporta exactamente igual que la oficial. Activa lo que necesites con `CREATE EXTENSION <nombre>` en cada base de datos.

Las marcadas como **preload** también hay que añadirlas a `shared_preload_libraries`, lo que requiere reiniciar:

```yaml
services:
  db:
    image: ruxwez/postgres:18-v1
    command: postgres -c shared_preload_libraries=pg_cron,timescaledb -c cron.database_name=postgres
```

Algunas advertencias:

- **pg_show_plans y timescaledb no se pueden precargar a la vez.** Insertar en una hypertable tumba el servidor (segfault). Precarga una u otra.
- **Muchas extensiones precargadas arrancan background workers.** Si precargas varias, sube `max_worker_processes` (por defecto es 8).
- **wal2json** necesita `wal_level = logical`. Las versiones menores recientes exigen además `output_plugin_libraries = 'wal2json'`.
- **pg_cron** y las extensiones que dependen de ella (`pg_incremental`, `documentdb`) solo funcionan en la base de datos indicada en `cron.database_name` (`postgres` por defecto).

## Por categoría

La columna **Origen** indica cómo llega cada extensión a la imagen:

- **PGDG**: paquete de [apt.postgresql.org](https://apt.postgresql.org).
- **Release**: paquete precompilado de los autores.
- **Imagen**: copiada de la imagen oficial de los autores.
- **Fuente**: compilada desde el código fuente.

### IA y vectores

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `vector` | [pgvector](https://github.com/pgvector/pgvector): búsqueda por similitud de vectores | PGDG | |
| `vectorscale` | [pgvectorscale](https://github.com/timescale/pgvectorscale): índice DiskANN para pgvector | Release | |

### Geoespacial

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `postgis` (+ `postgis_raster`, `postgis_topology`, `postgis_sfcgal`, `postgis_tiger_geocoder`) | [PostGIS](https://postgis.net/): tipos geometry y geography | PGDG | |
| `pgrouting` | [pgRouting](https://pgrouting.org/): rutas y análisis de redes sobre PostGIS | PGDG | |
| `h3`, `h3_postgis` | [h3-pg](https://github.com/postgis/h3-pg): rejilla hexagonal H3 de Uber | PGDG | |
| `pg_sphere` | [pgSphere](https://github.com/postgrespro/pgsphere): geometría esférica | PGDG | |

### Búsqueda y texto

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `pg_textsearch` | [pg_textsearch](https://github.com/timescale/pg_textsearch): búsqueda de texto completo con ranking BM25 | PGDG | preload; PG 17+ |
| `rum` | [RUM](https://github.com/postgrespro/rum): índice tipo GIN con ranking | PGDG | |
| `pg_bigm` | [pg_bigm](https://github.com/pgbigm/pg_bigm): búsqueda por bigramas, buena para CJK | Fuente | |
| `pg_similarity` | [pg_similarity](https://github.com/eulerto/pg_similarity): similitud de cadenas (Levenshtein, Jaro, coseno…) | PGDG | |
| `pgpcre` | [pgpcre](https://github.com/petere/pgpcre): expresiones regulares compatibles con Perl | PGDG | |
| `re2` | [pg_re2](https://github.com/ClickHouse/pg_re2): expresiones regulares RE2 | Imagen | |
| `icu_ext` | [icu_ext](https://github.com/dverite/icu_ext): funciones de ICU (transliteración, números en letra…) | PGDG | |

### Series temporales y analítica

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `timescaledb` | [TimescaleDB](https://github.com/timescale/timescaledb): hypertables y funciones de series temporales (edición Apache-2.0) | PGDG | preload |
| `pg_duckdb` | [pg_duckdb](https://github.com/duckdb/pg_duckdb): motor analítico DuckDB dentro de PostgreSQL | Imagen | preload |
| `pg_ivm` | [pg_ivm](https://github.com/sraoss/pg_ivm): vistas materializadas que se actualizan de forma incremental | PGDG | |
| `pg_incremental` | [pg_incremental](https://github.com/CrunchyData/pg_incremental): pipelines de procesamiento incremental | Fuente | necesita pg_cron; PG 15+ |
| `hll` | [postgresql-hll](https://github.com/citusdata/postgresql-hll): conteo de distintos con HyperLogLog | PGDG | |
| `tdigest` | [tdigest](https://github.com/tvondra/tdigest): estimación de percentiles | PGDG | |
| `roaringbitmap` | [pg_roaringbitmap](https://github.com/ChenHuajun/pg_roaringbitmap): bitmaps comprimidos | PGDG | |
| `first_last_agg` | [first_last_agg](https://github.com/wulczer/first_last_agg): agregados `first()` y `last()` | PGDG | |
| `extra_window_functions` | [extra_window_functions](https://github.com/xocolatl/extra_window_functions): más funciones de ventana | PGDG | |

### Colas, tareas y trabajo en segundo plano

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `pgmq` | [PGMQ](https://github.com/pgmq/pgmq): colas de mensajes | Fuente | |
| `pg_cron` | [pg_cron](https://github.com/citusdata/pg_cron): planificador de tareas estilo cron | PGDG | preload |
| `pg_background` | [pg_background](https://github.com/vibhorkum/pg_background): ejecutar SQL en background workers | PGDG | |
| `pg_partman` | [pg_partman](https://github.com/pgpartman/pg_partman): gestión automática de particiones | PGDG | preload para su background worker (opcional) |

### JSON, documentos y APIs

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `documentdb` | [DocumentDB](https://github.com/documentdb/documentdb): motor de documentos compatible con MongoDB | PGDG | preload; necesita pg_cron; PG 15+ |
| `pg_graphql` | [pg_graphql](https://github.com/supabase/pg_graphql): API GraphQL sobre tus tablas | Release | |
| `pg_jsonschema` | [pg_jsonschema](https://github.com/supabase/pg_jsonschema): validación con JSON Schema | Release | |
| `jsquery` | [jsquery](https://github.com/postgrespro/jsquery): lenguaje de consulta para JSON | PGDG | |
| `http` | [pgsql-http](https://github.com/pramsey/pgsql-http): cliente HTTP síncrono | PGDG | |
| `pg_net` | [pg_net](https://github.com/supabase/pg_net): peticiones HTTP asíncronas | Fuente | preload |
| `pgjwt` | [pgjwt](https://github.com/michelp/pgjwt): JSON Web Tokens | Fuente | |
| `postgres_protobuf` | [postgres-protobuf](https://github.com/mpartel/postgres-protobuf): consultar Protocol Buffers | Fuente | |
| `pg_csv` | [pg_csv](https://github.com/PostgREST/pg_csv): salida en CSV | PGDG | |

### Tipos de datos

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `age` | [Apache AGE](https://github.com/apache/age): base de datos de grafos con openCypher | PGDG | |
| `pg_uuidv7` | [pg_uuidv7](https://github.com/fboulnois/pg_uuidv7): UUIDv7 ordenados por tiempo | PGDG | |
| `pg_hashids` | [pg_hashids](https://github.com/iCyberon/pg_hashids): IDs cortos a partir de enteros | Fuente | |
| `ip4r` | [ip4r](https://github.com/RhodiumToad/ip4r): rangos IPv4/IPv6 | PGDG | |
| `prefix` | [prefix](https://github.com/dimitri/prefix): rangos de prefijos (enrutado telefónico…) | PGDG | |
| `semver` | [semver](https://github.com/theory/pg-semver): versiones semánticas | PGDG | |
| `pg_rational` | [pg_rational](https://github.com/begriffs/pg_rational): fracciones exactas | PGDG | |
| `timestamp9` | [timestamp9](https://github.com/optiver/timestamp9): timestamps con nanosegundos | PGDG | |
| `pg_rrule` | [pg_rrule](https://github.com/petropavel13/pg_rrule): reglas de recurrencia de iCalendar | PGDG | |
| `periods` | [periods](https://github.com/xocolatl/periods): periodos y versionado de sistema de SQL:2016 | PGDG | |
| `temporal_tables` | [temporal_tables](https://github.com/arkhipov/temporal_tables): tablas temporales de periodo de sistema | Fuente | |

### Replicación y CDC

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `pglogical` | [pglogical](https://github.com/2ndQuadrant/pglogical): replicación lógica | PGDG | preload; `wal_level = logical` |
| `wal2json` | [wal2json](https://github.com/eulerto/wal2json): plugin de salida JSON para decodificación lógica | PGDG | plugin de salida, ver advertencias |
| `pg_failover_slots` | [pg_failover_slots](https://github.com/EnterpriseDB/pg_failover_slots): slots lógicos que sobreviven a un failover | PGDG | preload; no se usa con `CREATE EXTENSION` |

### Monitorización y rendimiento

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `pg_stat_monitor` | [pg_stat_monitor](https://github.com/percona/pg_stat_monitor): estadísticas de consultas con histogramas | Fuente | preload |
| `pg_stat_kcache` | [pg_stat_kcache](https://github.com/powa-team/pg_stat_kcache): CPU y E/S por consulta | PGDG | preload, después de `pg_stat_statements` |
| `pg_qualstats` | [pg_qualstats](https://github.com/powa-team/pg_qualstats): estadísticas de predicados | PGDG | preload |
| `pg_wait_sampling` | [pg_wait_sampling](https://github.com/postgrespro/pg_wait_sampling): muestreo de eventos de espera | PGDG | preload |
| `pg_show_plans` | [pg_show_plans](https://github.com/cybertec-postgresql/pg_show_plans): planes de las consultas en curso | PGDG | preload; no junto con timescaledb |
| `pg_statviz` | [pg_statviz](https://github.com/vyruss/pg_statviz): snapshots de estadísticas | PGDG | |
| `hypopg` | [HypoPG](https://github.com/HypoPG/hypopg): índices hipotéticos | PGDG | |
| `pg_hint_plan` | [pg_hint_plan](https://github.com/ossc-db/pg_hint_plan): pistas al planificador en comentarios | PGDG | preload |
| `pgfincore` | [pgfincore](https://github.com/klando/pgfincore): inspección de la caché de páginas del SO | PGDG | |
| `pgnodemx` | [pgnodemx](https://github.com/CrunchyData/pgnodemx): métricas del SO y de cgroups | PGDG | preload |
| `prioritize` | [prioritize](https://github.com/schmiddy/pg_prioritize): prioridad de CPU de los backends | PGDG | |
| `toastinfo` | [toastinfo](https://github.com/credativ/toastinfo): cómo se almacenan los valores | PGDG | |
| `pg_dirtyread` | [pg_dirtyread](https://github.com/df7cb/pg_dirtyread): leer filas borradas | PGDG | |
| `pg_repack` | [pg_repack](https://github.com/reorg/pg_repack): reorganizar tablas en caliente | PGDG | |
| `pg_squeeze` | [pg_squeeze](https://github.com/cybertec-postgresql/pg_squeeze): recuperar espacio sin bloqueos pesados | PGDG | preload; `wal_level = logical` |

### Seguridad y auditoría

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `pgaudit` | [pgAudit](https://github.com/pgaudit/pgaudit): registro de auditoría | PGDG | preload |
| `anon` | [PostgreSQL Anonymizer](https://gitlab.com/dalibo/postgresql_anonymizer): enmascarado de datos | Release | preload |
| `pgsodium` | [pgsodium](https://github.com/michelp/pgsodium): criptografía con libsodium | Fuente | |
| `pg_pwhash` | [pg_pwhash](https://github.com/cybertec-postgresql/pg_pwhash): hash de contraseñas con scrypt, yescrypt y argon2 | PGDG | |
| `credcheck` | [credcheck](https://github.com/HexaCluster/credcheck): políticas de contraseñas y nombres de usuario | PGDG | preload |
| `set_user` | [set_user](https://github.com/pgaudit/set_user): cambio de rol auditado | PGDG | preload |
| `pg_permissions` | [pg_permissions](https://github.com/cybertec-postgresql/pg_permissions): revisar todos los permisos | PGDG | |

### Datos externos

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `wrappers` | [Wrappers](https://github.com/supabase/wrappers): foreign data wrappers para Stripe, S3, BigQuery… | Release | |
| `pg_clickhouse` | [pg_clickhouse](https://github.com/ClickHouse/pg_clickhouse): consultar ClickHouse | Imagen | |
| `tds_fdw` | [tds_fdw](https://github.com/tds-fdw/tds_fdw): consultar SQL Server y Sybase | PGDG | |

### Desarrollo y testing

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `pgtap` | [pgTAP](https://pgtap.org/): tests unitarios en SQL | PGDG | |
| `plpgsql_check` | [plpgsql_check](https://github.com/okbob/plpgsql_check): linter de PL/pgSQL | PGDG | |
| `plprofiler` | [plprofiler](https://github.com/bigsql/plprofiler): profiler de PL/pgSQL | PGDG | preload |
| `pljs` | [PLJS](https://github.com/plv8/pljs): lenguaje procedural JavaScript (QuickJS) | PGDG | |

### Compatibilidad

| Extensión | Descripción | Origen | Notas |
|---|---|---|---|
| `orafce` | [Orafce](https://github.com/orafce/orafce): funciones y paquetes de Oracle | PGDG | |
| `pgtt` | [pgtt](https://github.com/darold/pgtt): tablas temporales globales al estilo Oracle | PGDG | `LOAD 'pgtt'` en cada sesión |
| `db2fce` | [db2fce](https://github.com/credativ/db2fce): funciones de DB2 | PGDG | |

## No incluidas

Estas extensiones se evaluaron, pero no están en la imagen:

| Extensión | Por qué |
|---|---|
| [plv8](https://github.com/plv8/plv8) | Necesita compilar V8 desde el código fuente para cada arquitectura: horas de build y gigas de caché por imagen. En su lugar se incluye `pljs` (JavaScript sobre QuickJS). |
| [pg_lake](https://github.com/Snowflake-Labs/pg_lake) | Trae su propio DuckDB, que choca con `pg_duckdb` en el mismo servidor, y necesita un toolchain pesado de C++/vcpkg. |
| [pg_durable](https://github.com/microsoft/pg_durable) | Solo se publica para PostgreSQL 17–18 en amd64; arm64 y las versiones anteriores necesitarían compilar con Rust (pgrx). |

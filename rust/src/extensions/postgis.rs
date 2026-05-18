use std::sync::{Arc, LazyLock};

use crate::{common::run, structs::ExtensionVersionCompatibility};

// Versiones de PostGIS para cada version de PostgreSQL
static VERSIONS: LazyLock<ExtensionVersionCompatibility> =
    LazyLock::new(|| ExtensionVersionCompatibility {
        v16: "3",
        v17: "3",
        v18: "3",
    });

// Instala PostGIS via apt-get
pub fn install(pg_version: Arc<String>) {
    let pg_major = pg_version.split('.').next().unwrap();

    let ex_version = VERSIONS
        .get_version(pg_major)
        .expect("Unsupported PostgreSQL version");

    run(&format!(
        "apt-get install -y \
           postgresql-{}-postgis-{} \
           postgresql-{}-postgis-{}-scripts",
        pg_major, ex_version, pg_major, ex_version
    ));
}

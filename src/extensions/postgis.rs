use std::sync::{Arc, LazyLock};

use crate::{common::run, print_error, structs::ExtensionVersionCompatibility, test};

static VERSIONS: LazyLock<ExtensionVersionCompatibility> =
    LazyLock::new(|| ExtensionVersionCompatibility {
        v16: "3",
        v17: "3",
        v18: "3",
    });

pub fn install(pg_version: Arc<String>) {
    let pg_major = pg_version.to_owned().split('.').next().unwrap().to_owned();

    let ex_version = match VERSIONS.get_version(&pg_major.clone()) {
        Some(v) => v,
        None => panic!("Unsupported PostgreSQL version"),
    };

    run(&format!(
        "apt-get install -y \
           postgresql-{}-postgis-{} \
           postgresql-{}-postgis-{}-scripts",
        pg_major, ex_version, pg_major, ex_version
    ));
}

pub async fn run_test() {
    let pool = test::get_pool();

    sqlx::query("CREATE EXTENSION postgis")
        .execute(pool)
        .await
        .unwrap_or_else(|_| print_error!("Error to create postgis extension"));
}

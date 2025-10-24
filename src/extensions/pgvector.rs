use crate::{common::run, structs::ExtensionVersionCompatibility, test};
use std::{
    fs,
    sync::{Arc, LazyLock},
};
use tokio::task::JoinHandle;

static VERSIONS: LazyLock<ExtensionVersionCompatibility> =
    LazyLock::new(|| ExtensionVersionCompatibility {
        v16: "0.8.1",
        v17: "0.8.1",
        v18: "0.8.1",
    });

pub fn install(pg_version: Arc<String>) -> JoinHandle<()> {
    let version = match VERSIONS.get_version(&pg_version.to_owned()) {
        Some(v) => v,
        None => panic!("Unsupported PostgreSQL version"),
    };

    tokio::task::spawn_blocking(move || {
        // Clone the repository
        run(&format!(
            "git clone --branch v{} --depth 1 https://github.com/pgvector/pgvector.git /tmp/pgvector",
            version
        ));

        // Build and install pgvector
        run("cd /tmp/pgvector && make clean && make OPTFLAGS='' && make install");

        // Clean up the temporary directory
        fs::remove_dir_all("/tmp/pgvector").ok();
    })
}

pub async fn run_test() {
    let pool = test::get_pool();

    sqlx::query("CREATE EXTENSION vector")
        .execute(pool)
        .await
        .expect("Error to verify postgis extension");
}

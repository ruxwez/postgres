use crate::{common::run, print_error, structs::ExtensionVersionCompatibility, test};
use std::{
    fs,
    sync::{Arc, LazyLock},
};
use tokio::task::JoinHandle;

static VERSIONS: LazyLock<ExtensionVersionCompatibility> =
    LazyLock::new(|| ExtensionVersionCompatibility {
        v16: "1.7.0",
        v17: "1.7.0",
        v18: "1.7.0",
    });

pub fn install(pg_version: Arc<String>) -> JoinHandle<()> {
    let version = match VERSIONS.get_version(&pg_version.to_owned()) {
        Some(v) => v,
        None => print_error!("Unsupported PostgreSQL version"),
    };

    tokio::task::spawn_blocking(move || {
        run(&format!(
            "git clone --branch v{} --depth 1 https://github.com/pgmq/pgmq.git /tmp/pgmq",
            version
        ));

        run("cd /tmp/pgmq/pgmq-extension && make && make install");
        fs::remove_dir_all("/tmp/pgmq").ok();
    })
}

pub async fn run_test() {
    let pool = test::get_pool();

    sqlx::query("CREATE EXTENSION pgmq")
        .execute(pool)
        .await
        .unwrap_or_else(|_| print_error!("Error to create pgmq extension"));
}

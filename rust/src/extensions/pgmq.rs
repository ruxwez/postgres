use std::{fs, sync::{Arc, LazyLock}};

use crate::{common::run, structs::ExtensionVersionCompatibility};
use tokio::task::JoinHandle;

// Versiones de pgmq para cada version de PostgreSQL
static VERSIONS: LazyLock<ExtensionVersionCompatibility> =
    LazyLock::new(|| ExtensionVersionCompatibility {
        v16: "1.7.0",
        v17: "1.7.0",
        v18: "1.7.0",
    });

// Compila e instala pgmq desde fuente en un hilo bloqueante
pub fn install(pg_version: Arc<String>) -> JoinHandle<()> {
    let version = VERSIONS
        .get_version(&pg_version)
        .expect("Unsupported PostgreSQL version");

    tokio::task::spawn_blocking(move || {
        run(&format!(
            "git clone --branch v{} --depth 1 \
             https://github.com/pgmq/pgmq.git /tmp/pgmq",
            version
        ));
        run("cd /tmp/pgmq/pgmq-extension && make && make install");
        fs::remove_dir_all("/tmp/pgmq").ok();
    })
}

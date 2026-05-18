use std::{fs, sync::{Arc, LazyLock}};

use crate::{common::run, structs::ExtensionVersionCompatibility};
use tokio::task::JoinHandle;

// Versiones de pgvector para cada version de PostgreSQL
static VERSIONS: LazyLock<ExtensionVersionCompatibility> =
    LazyLock::new(|| ExtensionVersionCompatibility {
        v16: "0.8.1",
        v17: "0.8.1",
        v18: "0.8.1",
    });

// Compila e instala pgvector desde fuente en un hilo bloqueante
pub fn install(pg_version: Arc<String>) -> JoinHandle<()> {
    let version = VERSIONS
        .get_version(&pg_version)
        .expect("Unsupported PostgreSQL version");

    tokio::task::spawn_blocking(move || {
        run(&format!(
            "git clone --branch v{} --depth 1 \
             https://github.com/pgvector/pgvector.git /tmp/pgvector",
            version
        ));
        run("cd /tmp/pgvector && make clean && make OPTFLAGS='' && make install");
        fs::remove_dir_all("/tmp/pgvector").ok();
    })
}

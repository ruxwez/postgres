use crate::{common::run, structs::ExtensionVersionCompatibility};
use std::{
    fs,
    sync::{Arc, LazyLock},
};
use tokio::task::JoinHandle;

static VERSIONS: LazyLock<Arc<ExtensionVersionCompatibility>> = LazyLock::new(|| {
    Arc::new(ExtensionVersionCompatibility {
        v16: "1.7.0",
        v17: "1.7.0",
        v18: "1.7.0",
    })
});

pub fn install(pg_version: Arc<String>) -> JoinHandle<()> {
    let version = match VERSIONS.get_version(&pg_version.to_owned()) {
        Some(v) => v,
        None => panic!("Unsupported PostgreSQL version"),
    };

    tokio::spawn(async move {
        tokio::task::spawn_blocking(move || {
            run(&format!(
                "git clone --branch v{} --depth 1 https://github.com/pgmq/pgmq.git /tmp/pgmq",
                version
            ));

            run("cd /tmp/pgmq/pgmq-extension && make && make install");
            fs::remove_dir_all("/tmp/pgmq").ok();
        })
        .await
        .expect("Blocking task failed");
    })
}

use crate::common::run;
use std::fs;
use tokio::task::JoinHandle;

static EXTENSION_VERSION: &str = "0.8.1";

pub fn install() -> JoinHandle<()> {
    tokio::spawn(async move {
        tokio::task::spawn_blocking(|| {
            // Clone the repository
            run(&format!(
                "git clone --branch v{} --depth 1 https://github.com/pgvector/pgvector.git /tmp/pgvector",
                EXTENSION_VERSION
            ));

            // Build and install pgvector
            run("cd /tmp/pgvector && make clean && make OPTFLAGS='' && make install");

            // Clean up the temporary directory
            fs::remove_dir_all("/tmp/pgvector").ok();
        }).await.expect("Blocking task failed");
    })
}

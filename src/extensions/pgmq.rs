use crate::common::run;
use std::fs;
use tokio::task::JoinHandle;

static EXTENSION_VERSION: &str = "1.7.0";

pub fn install() -> JoinHandle<()> {
    tokio::spawn(async move {
        tokio::task::spawn_blocking(|| {
            run(&format!(
                "git clone --branch v{} --depth 1 https://github.com/pgmq/pgmq.git /tmp/pgmq",
                EXTENSION_VERSION
            ));

            run("cd /tmp/pgmq/pgmq-extension && make && make install");
            fs::remove_dir_all("/tmp/pgmq").ok();
        })
        .await
        .expect("Blocking task failed");
    })
}

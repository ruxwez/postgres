use crate::common::run;
use std::fs;
use tokio::task::JoinHandle;

pub fn install() -> JoinHandle<()> {
    tokio::spawn(async move {
        run("git clone https://github.com/pgmq/pgmq.git /tmp/pgmq");
        run("cd /tmp/pgmq/pgmq-extension && make && make install");
        fs::remove_dir_all("/tmp/pgmq").ok();
    })
}

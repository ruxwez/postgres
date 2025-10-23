use crate::common::{get_latest_tag, run};
use std::fs;
use tokio::task::JoinHandle;

pub fn install() -> JoinHandle<()> {
    tokio::spawn(async move {
        // Get the latest tag from the pgvector GitHub repository
        let latest_tag = get_latest_tag("https://github.com/pgvector/pgvector.git");

        // Clone the repository at the latest tag
        run(&format!(
            "git clone --branch {} --depth 1 https://github.com/pgvector/pgvector.git /tmp/pgvector",
            latest_tag
        ));

        // Build and install pgvector
        run("cd /tmp/pgvector && make clean && make OPTFLAGS='' && make install");

        // Clean up the temporary directory
        fs::remove_dir_all("/tmp/pgvector").ok();
    })
}

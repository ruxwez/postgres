use std::sync::Arc;

use crate::common::{detect_postgres_version, run};

mod common;
mod extensions;
mod structs;

#[tokio::main]
async fn main() {
    // Detecta automaticamente la version de PostgreSQL instalada
    println!("Detecting PostgreSQL version...");
    let pg_version = Arc::new(detect_postgres_version());
    let pg_major = pg_version.split('.').next().unwrap();

    println!("Detected PostgreSQL version: {}", pg_version);
    println!("Installing build dependencies...");
    run(&format!(
        "apt-get update && apt-get install -y --no-install-recommends \
         postgresql-contrib git build-essential \
         postgresql-server-dev-{} ca-certificates",
        pg_major
    ));

    println!("Installing extensions in parallel...");
    extensions::install(pg_version.clone()).await;

    println!("Cleaning up to reduce image size...");
    run(&format!(
        "apt-get purge -y --auto-remove git build-essential \
         postgresql-server-dev-{} \
         && apt-get autoremove -y && apt-get clean \
         && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache \
         /var/cache/apt/* /usr/share/doc/* /usr/share/man/* \
         && find /var/log -type f -delete",
        pg_major
    ));

    println!("Installation completed successfully!");
}

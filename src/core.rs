use std::sync::Arc;

use crate::{common::run, extensions};

pub async fn installer(pg_version: String) {
    if !cfg!(unix) {
        panic!("❌ The installer only supports Unix-like operating systems.");
    }

    let pg_version = Arc::new(pg_version);

    let pg_major = pg_version.split(".").next().unwrap();

    println!(
        "🚀 Installing PostgreSQL extensions for version {}",
        pg_version
    );

    // Install necessary packages
    println!("📦 Installing build dependencies...");
    run(&format!(
        "apt-get update && apt-get install -y --no-install-recommends \
         postgresql-contrib \
         git \
         build-essential \
         postgresql-server-dev-{} \
         ca-certificates",
        pg_major
    ));

    // Install extensions
    println!("🔧 Installing extensions in parallel...");
    extensions::install(pg_version.clone()).await;

    // Clean up build packages to reduce image size
    println!("🧹 Cleaning up to reduce image size...");
    run(&format!(
        "apt-get purge -y --auto-remove \
         git \
         build-essential \
         postgresql-server-dev-{} \
         && apt-get autoremove -y \
         && apt-get clean \
         && rm -rf /var/lib/apt/lists/* \
         && rm -rf /tmp/* \
         && rm -rf /var/tmp/* \
         && rm -rf /root/.cache \
         && rm -rf /var/cache/apt/* \
         && rm -rf /usr/share/doc/* \
         && rm -rf /usr/share/man/* \
         && find /var/log -type f -delete",
        pg_major
    ));

    println!("✅ Installation completed successfully!");
}

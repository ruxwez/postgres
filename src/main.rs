use std::{env, sync::Arc};

use crate::common::{run, run_output};

mod common;
mod extensions;
mod structs;

#[tokio::main]
async fn main() {
    // Collect command-line arguments
    let args: Vec<String> = env::args().collect();

    if args.len() != 2 {
        panic!("Insert PostgreSQL version as argument");
    }

    // If user passed "latest", detect the numeric version from the installed postgres binary.
    // Otherwise use the provided version string (e.g. "15.3" or "15").
    let mut pg_version = args[1].clone();
    if pg_version.eq_ignore_ascii_case("latest") {
        println!("🔎 Detecting PostgreSQL version from the base image (requested: latest)...");
        // Try `postgres --version`. This requires that the base image already provides the postgres binary.
        let ver_output = run_output("postgres --version");
        // Typical output: "postgres (PostgreSQL) 15.3"
        // We take the last whitespace-separated token as the numeric version.
        let numeric_version = ver_output
            .split_whitespace()
            .last()
            .expect("Failed to parse postgres --version output")
            .to_string();

        println!("ℹ️ Detected PostgreSQL version: {}", numeric_version);
        pg_version = numeric_version;
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
        "set -e && \
         apt-get update && \
         apt-get upgrade -y && \
         apt-get install -y --no-install-recommends \
             postgresql-contrib \
             git \
             build-essential \
             postgresql-server-dev-{} \
             ca-certificates && \
         apt-get autoremove -y && \
         apt-get clean && \
         rm -rf /var/lib/apt/lists/*",
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

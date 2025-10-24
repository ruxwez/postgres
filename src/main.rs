use clap::Parser;

mod common;
mod core;
mod extensions;
mod structs;
mod tests;

#[tokio::main]
async fn main() {
    let cli = structs::CLI::parse();

    if cli.test_mode {
        return tests::run().await;
    }

    // If user passed "latest", detect the numeric version from the installed postgres binary.
    // Otherwise use the provided version string (e.g. "15.3" or "15").
    let mut pg_version = cli.pg_version;
    if pg_version == "ignore" {
        panic!("Error: --pg-version is required.");
    }

    if pg_version.eq_ignore_ascii_case("latest") {
        pg_version = common::get_current_postgres_version()
    }

    core::installer(pg_version).await;
}

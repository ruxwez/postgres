use clap::Parser;

mod common;
mod core;
mod extensions;
mod structs;
mod test;

#[tokio::main]
async fn main() {
    let cli = structs::CLI::parse();

    if cli.test_mode {
        test::init_db_pool().await;

        return extensions::run_tests().await;
    }

    let pg_version = common::get_current_postgres_version();
    if pg_version == "" {
        print_error!("Error detecting PostgreSQL version");
    }

    core::installer(pg_version).await;
}

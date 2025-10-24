use sqlx::{Pool, Postgres, postgres::PgPoolOptions};
use std::sync::OnceLock;

use crate::print_error;

static POOL: OnceLock<Pool<Postgres>> = OnceLock::new();

pub async fn init_db_pool() {
    let pool_options = PgPoolOptions::new()
        .max_connections(10)
        .connect(&format!(
            "postgres://postgres:testmode@127.0.0.1:5432/postgres"
        ))
        .await
        .unwrap_or_else(|_| {
            print_error!("Failed to connect to the Postgres database");
        });

    POOL.set(pool_options)
        .unwrap_or_else(|_| print_error!("Postgres Pool already initialized"));
}

pub fn get_pool() -> &'static Pool<Postgres> {
    POOL.get()
        .unwrap_or_else(|| print_error!("Postgres Pool not initialized"))
}

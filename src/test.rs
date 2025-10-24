use sqlx::{Pool, Postgres, postgres::PgPoolOptions};
use std::sync::OnceLock;

static POOL: OnceLock<Pool<Postgres>> = OnceLock::new();

pub async fn init_db_pool() {
    let pool_options = PgPoolOptions::new()
        .max_connections(10)
        .connect(&format!(
            "postgres://postgres:testmode@127.0.0.1:5432/postgres"
        ))
        .await
        .unwrap();

    POOL.set(pool_options).expect("Failed to set Postgres pool");
}

pub fn get_pool() -> &'static Pool<Postgres> {
    POOL.get().expect("Postgres pool not initialized")
}

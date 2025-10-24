use std::sync::Arc;

mod pgmq;
mod pgvector;
mod postgis;

pub async fn install(pg_version: Arc<String>) {
    postgis::install(pg_version.clone());

    let pgmq_handle = pgmq::install(pg_version.clone());
    let pgvector_handle = pgvector::install(pg_version.clone());

    // Wait for all installations to complete
    let _ = tokio::join!(pgmq_handle, pgvector_handle);
}

pub async fn run_tests() {
    postgis::run_test().await;
    pgvector::run_test().await;
    pgmq::run_test().await;

    println!("All extension tests passed!");
}

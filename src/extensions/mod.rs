mod pgmq;
mod pgvector;
mod postgis;

pub async fn install(pg_version: String) {
    postgis::install(pg_version);

    let pgmq_handle = pgmq::install();
    let pgvector_handle = pgvector::install();

    // Wait for all installations to complete
    let _ = tokio::join!(pgmq_handle, pgvector_handle);
}

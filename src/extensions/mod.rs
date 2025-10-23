mod pgmq;
mod pgvector;
mod postgis;

pub async fn install(pg_version: String) {
    let pgmq_handle = pgmq::install();
    let pgvector_handle = pgvector::install();
    let postgis_handle = postgis::install(pg_version);

    // Wait for all installations to complete
    let _ = tokio::join!(pgmq_handle, pgvector_handle, postgis_handle);
}

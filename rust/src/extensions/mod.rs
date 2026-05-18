use std::sync::Arc;

mod pgmq;
mod pgvector;
mod postgis;

// Instala todas las extensiones en paralelo
pub async fn install(pg_version: Arc<String>) {
    postgis::install(pg_version.clone());

    let pgmq = pgmq::install(pg_version.clone());
    let pgvector = pgvector::install(pg_version);

    let _ = tokio::join!(pgmq, pgvector);
}

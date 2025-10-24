use std::time::Duration;

use tokio::time::sleep;

mod config;

pub async fn run() {
    sleep(Duration::from_secs(100)).await;
}

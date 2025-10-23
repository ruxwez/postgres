use crate::common::run;
use tokio::task::JoinHandle;

pub fn install(pg_version: String) -> JoinHandle<()> {
    let pg_major = pg_version.split('.').next().unwrap().to_owned();

    tokio::spawn(async move {
        run(&format!(
            "apt-get install -y \
               postgresql-{}-postgis-3 \
               postgresql-{}-postgis-3-scripts",
            pg_major, pg_major
        ));
    })
}

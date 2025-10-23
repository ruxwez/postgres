use crate::common::run;

static EXTENSION_VERSION: &str = "3";

pub fn install(pg_version: String) {
    let pg_major = pg_version.split('.').next().unwrap().to_owned();

    run(&format!(
        "apt-get install -y \
           postgresql-{}-postgis-{} \
           postgresql-{}-postgis-{}-scripts",
        pg_major, EXTENSION_VERSION, pg_major, EXTENSION_VERSION
    ));
}

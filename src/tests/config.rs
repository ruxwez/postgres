use std::{env, sync::OnceLock};

#[derive(Debug)]
pub struct Config {
    pub PG_PASSWORD: String,
    pub PG_USER: String,
    pub PG_DB: String,
}

static CONFIG: OnceLock<Config> = OnceLock::new();

pub fn init() {
    let config = Config {
        PG_PASSWORD: env::var("PG_PASSWORD").expect("Error to get Postgres Password"),
        PG_DB: "postgres".to_owned(),
        PG_USER: "postgres".to_owned(),
    };

    CONFIG.set(config).expect("Failed to set config");
}

pub fn get() -> &'static Config {
    CONFIG.get().expect("Config not initialized")
}

use clap::Parser;

pub struct ExtensionVersionCompatibility<'a> {
    pub v16: &'a str,
    pub v17: &'a str,
    pub v18: &'a str,
}

impl ExtensionVersionCompatibility<'static> {
    pub fn get_version(&self, version: &str) -> Option<String> {
        if version.contains('.') {
            let major_version = version.split('.').next().unwrap();
            return self.get_version(major_version);
        }

        match version.to_string().as_str() {
            "16" => Some(self.v16.to_string()),
            "17" => Some(self.v17.to_string()),
            "18" => Some(self.v18.to_string()),
            _ => None,
        }
    }
}

#[derive(Parser, Debug)]
pub struct CLI {
    // Test mode
    #[arg(short, long, default_value_t = false)]
    pub test_mode: bool,

    // PG Version
    #[arg(long, default_value_t = String::from("ignore"))]
    pub pg_version: String,
}

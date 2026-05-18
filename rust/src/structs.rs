// Mapea versiones de PostgreSQL a versiones compatibles de cada extension
pub struct ExtensionVersionCompatibility {
    pub v16: &'static str,
    pub v17: &'static str,
    pub v18: &'static str,
}

impl ExtensionVersionCompatibility {
    // Obtiene la version de la extension segun la version mayor de Postgres
    pub fn get_version(&self, version: &str) -> Option<String> {
        let major = version.split('.').next().unwrap_or(version);
        match major {
            "16" => Some(self.v16.to_string()),
            "17" => Some(self.v17.to_string()),
            "18" => Some(self.v18.to_string()),
            _ => None,
        }
    }
}

use std::process::Command;

use regex::Regex;

// Ejecuta un comando shell y paniquea si falla
pub fn run(cmd: &str) {
    let status = Command::new("sh")
        .arg("-c")
        .arg(cmd)
        .status()
        .expect("Failed to execute command");

    if !status.success() {
        panic!("Command failed: {}", cmd);
    }
}

// Ejecuta un comando shell y devuelve su stdout como String
pub fn run_output(cmd: &str) -> String {
    let output = Command::new("sh")
        .arg("-c")
        .arg(cmd)
        .output()
        .expect("Failed to execute command");

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        panic!("Command failed: {}\nstderr: {}", cmd, stderr);
    }

    String::from_utf8_lossy(&output.stdout).trim().to_string()
}

// Detecta la version de PostgreSQL ejecutando "postgres --version" y extrayendo el numero con regex
pub fn detect_postgres_version() -> String {
    let output = run_output("postgres --version");
    let re = Regex::new(r"(\d+\.\d+)").expect("Invalid regex");
    let caps = re
        .captures(&output)
        .expect("Failed to parse postgres --version output");
    caps[1].to_string()
}

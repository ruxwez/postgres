use std::process::Command;

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

/// Run a shell command and return its stdout as a trimmed String.
/// Panics if the command fails to execute or returns a non-zero exit code.
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

pub fn get_current_postgres_version() -> String {
    println!("🔎 Detecting PostgreSQL version from the base image (requested: latest)...");
    // Try `postgres --version`. This requires that the base image already provides the postgres binary.
    let ver_output = run_output("postgres --version");
    // Typical output: "postgres (PostgreSQL) 15.3"
    // We take the last whitespace-separated token as the numeric version.
    let numeric_version = ver_output
        .split_whitespace()
        .last()
        .expect("Failed to parse postgres --version output")
        .to_string();

    println!("ℹ️ Detected PostgreSQL version: {}", numeric_version);

    numeric_version
}

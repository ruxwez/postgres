use std::process::Command;

#[macro_export]
macro_rules! print_error {
    ($($arg:tt)*) => {{
        eprintln!("❌ | {}", format!($($arg)*));
        std::process::exit(1);
    }};
}

#[macro_export]
macro_rules! print_message {
    ($($arg:tt)*) => {{
        println!("💠 | {}", format!($($arg)*));
    }};
}

#[macro_export]
macro_rules! print_success {
    ($($arg:tt)*) => {{
        println!("💠 | {}", format!($($arg)*));
    }};
}

pub fn run(cmd: &str) {
    let status = Command::new("sh")
        .arg("-c")
        .arg(cmd)
        .status()
        .unwrap_or_else(|_| {
            print_error!("Failed to execute command: {}", cmd);
        });

    if !status.success() {
        print_error!("Command failed: {}", cmd);
    }
}

/// Run a shell command and return its stdout as a trimmed String.
/// Panics if the command fails to execute or returns a non-zero exit code.
pub fn run_output(cmd: &str) -> String {
    let output = Command::new("sh")
        .arg("-c")
        .arg(cmd)
        .output()
        .unwrap_or_else(|_| {
            print_error!("Failed to execute command: {}", cmd);
        });

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        print_error!("Command failed: {}\nstderr: {}", cmd, stderr);
    }

    String::from_utf8_lossy(&output.stdout).trim().to_string()
}

pub fn get_current_postgres_version() -> String {
    print_message!("🔎 Detecting PostgreSQL version from the base image (requested: latest)...");
    // Try `postgres --version`. This requires that the base image already provides the postgres binary.
    let ver_output = run_output("postgres --version");
    // Typical output: "postgres (PostgreSQL) 15.3"
    // We take the last whitespace-separated token as the numeric version.
    let numeric_version = ver_output
        .split_whitespace()
        .last()
        .unwrap_or_else(|| {
            print_error!("Error detecting PostgreSQL version");
        })
        .to_string();

    print_success!("ℹ️ Detected PostgreSQL version: {}", numeric_version);

    numeric_version
}

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

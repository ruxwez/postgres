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

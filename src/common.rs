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

pub fn get_latest_tag(repo: &str) -> String {
    let output = Command::new("git")
        .args(&["ls-remote", "--tags", "--sort=-v:refname", repo])
        .output()
        .expect("Failed to get latest tag");

    let stdout = String::from_utf8_lossy(&output.stdout);
    // Take the first non-empty line (equivalent to the previous pipeline's `head -n1`)
    let first_line = stdout.lines().find(|l| !l.trim().is_empty()).unwrap_or("");

    if first_line.is_empty() {
        return String::new();
    }

    // Each line is "<hash>\trefs/tags/<tag>" (possibly with a trailing ^{} for dereferenced annotated tags)
    let parts: Vec<&str> = first_line.split_whitespace().collect();
    if parts.len() < 2 {
        return String::new();
    }

    let tag_ref = parts[1];
    // Remove the "refs/tags/" prefix and any trailing "^{}"
    let tag = tag_ref
        .strip_prefix("refs/tags/")
        .unwrap_or(tag_ref)
        .trim_end_matches("^{}")
        .to_string();

    tag
}

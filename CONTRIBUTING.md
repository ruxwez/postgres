# Contributing to PostgreSQL Extensions Installer

Thank you for your interest in contributing! This document explains how to report problems, propose features, contribute code (including new extensions), and how to prepare a clear PR so maintainers can review and merge your changes quickly.

Contents
- Reporting issues or proposing features
- Contributing code (high-level workflow)
- Pull request checklist
- How the extension system works
- How to add a new extension (step-by-step)
- Coding and style notes
- Continuous Integration / tests
- License and code of conduct

---

## Reporting issues or proposing features

- If you found a bug, please open an Issue using the **Bug Report** template.
- If you want to propose a new feature (including adding a new extension), open an Issue using the **Feature Request** template.

Every issue should include:
- A clear title and a short description.
- Steps to reproduce (if it's a bug).
- Expected behavior vs actual behavior.
- The environment you used (docker image / base postgres version used, OS if relevant).
- Logs / command output (when applicable).

Before opening an issue:
1. Search existing issues to avoid duplicates.
2. If you plan to implement the fix or feature, mention that in the issue to avoid duplicated work.

---

## Contributing code — high-level workflow

1. Fork the repository.
2. Create a feature branch named using the pattern:
   - `fix/<short-description>`, or
   - `feat/<short-description>`, or
   - `ext/<extension-name>` (for new extension work)
3. If you are implementing a non-trivial change, create an Issue first (see above). If none exists, create one and reference it from your PR.
4. Implement your changes. Build and test locally (see "CI / tests" below).
5. Create a pull request (PR) from your branch to `main` with a descriptive title.
6. In the PR description include:
   - Motivation and summary of changes.
   - How to test locally (commands and examples).
   - Linked issue number (if any).
7. Wait for CI and maintainers' review. Respond to review comments and iterate as needed.

---

## Pull request checklist

Before requesting review, make sure:

- [ ] You signed and/or accepted the project license terms by contributing (the repository uses an open source license in `LICENSE`).
- [ ] You created / linked an Issue describing the problem or feature (unless the change is trivial).
- [ ] Your branch is based on the latest `main`.
- [ ] The code compiles: `cargo build --release`.
- [ ] You included testing steps in the PR description.
- [ ] You documented any new public API, command-line behavior, or Docker build args.
- [ ] You updated relevant docs (README or this CONTRIBUTING file if needed).

GitHub Actions are configured to perform build tests for multiple Postgres versions. The CI matrix is defined in `.github/workflows/pr-test.yml`.


---

## Coding and style notes

- This project uses stable Rust with `tokio` for concurrency.
- Keep code simple and robust: handle command failures and avoid silent errors.
- Use `crate::common::run(...)` and `run_output(...)` rather than reimplementing command execution.
- When adding new public API surfaces, document them in the README and update the top-level README with notes for the new extension.

---

## CI and testing

- PRs trigger a matrix build defined in `.github/workflows/pr-test.yml`. The CI builds images for multiple Postgres versions and architectures.
- Ensure your changes are compatible across the supported Postgres versions listed in the matrix (see the workflow file).
- If your change only affects docs, you can still create a PR, and maintainers may merge it if checks are satisfied.

---

## Documentation updates

- Update `README.md` when adding new extensions or changing default behavior.
- For Spanish users, there's a `README.es.md` — when adding content that should appear in the Spanish readme, propose a matching translation or open an issue asking for assistance.

Suggested README link updates:
- Add a link to this file in `README.md`:
  - `See CONTRIBUTING.md for contribution guidelines.`
- Add a link to the Spanish copy (when created) in `README.es.md`.

---

## Questions and support

If you need help deciding how to implement an extension or want feedback before coding, open an Issue with the "feature request" template describing your plan and the extension you want to add.

---

Thank you for helping improve this project — contributions are very welcome!

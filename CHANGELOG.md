## [Unreleased]

- Do not check files in `vendor/`

## [0.0.3] - 2026-02-15

- exit with non-zero exit code if any violations are found

## [0.0.2] - 2026-02-15

- MVP: Basic architecture enforcement with layered architecture support
- **breaking:** invoke stellwerk via rake task (`rails stellwerk:check`), the executable is removed
- pull actual autoloaders from application, or use faked autoloaders to omit app startup via `rails stellwerk:check_simple`

## [0.0.1] - 2025-12-10

- Initial release without any functionality. Essentially, name squatting.

# Changelog

All notable changes to lazypac are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/).

---

## [1.2.0] - 2026-05-17

### Added
- `cache-size`: shows total size and file count of `/var/cache/pacman/pkg/`
- `cache-clean-old`: removes cached packages that are no longer installed (`paccache -ruk0`, requires `pacman-contrib`)

### Changed
- `clean` renamed to `cache-clean` for consistency with the new cache command group
- `clean-all` renamed to `cache-clean-all`
- `cache-clean` and `cache-clean-all` now call `sudo pacman` directly instead of the AUR helper, fixing a bug where yay/paru could not write to `/var/cache/pacman/pkg/` without privilege escalation
- `update` now asks for confirmation before running `-Sy`, with a warning about partial upgrade state
- `safe-upgrade` aborts with an error if the pre-upgrade snapshot fails

### Breaking
- `clean` and `clean-all` no longer exist; use `cache-clean` and `cache-clean-all`

---

## [1.1.1] - 2026-05-16

### Fixed
- `update`: added a warning that `-Sy` without upgrade can leave the system in a partial upgrade state on Arch Linux
- `safe-upgrade`: aborts and skips log generation if the upgrade fails
- `safe-upgrade`: log header corrected from "Package manager" to "AUR helper"
- `check`: exits with code `1` if any queried package is not installed (was always `0`)
- `log`: rejects filenames containing `/` to prevent reading files outside the log directory

---

## [1.1.0] - 2026-05-16

### Added
- Automatic fallback to plain `pacman` when neither `yay` nor `paru` is found; write operations run with `sudo` automatically in fallback mode
- Missing-argument guards on all commands that require a package name
- `safe-upgrade`: upgrade with before/after snapshot, version diff log saved to `~/.local/share/lazypac/`, and `.pacnew`/`.pacsave` check after upgrade
- `log`, `log <file>`, `logclean`: manage upgrade logs
- `remove-orphans`: removes orphan packages, handles the empty-list edge case
- `deps`: dependency tree via `pactree` (requires `pacman-contrib`)
- `check`: check one or more packages by name
- `pacnew`: find `.pacnew` and `.pacsave` files in `/etc`
- Flag passthrough: extra arguments are forwarded verbatim to the underlying tool
- BATS test suite split across `test_packages.sh`, `test_query.sh`, `test_logs.sh`, `test_misc.sh`
- CI via GitHub Actions (ShellCheck + BATS)

### Changed
- `orphans` uses `$PKG -Qdt` directly; prints "No orphan packages." when none are found

---

## [1.0.0] - 2026-05-14

Initial release. Basic wrapper for `yay`/`paru` with human-readable subcommands:
`install`, `remove`, `purge`, `update`, `upgrade`, `search`, `info`, `list`,
`installed`, `orphans`, `clean`, `clean-all`.
Man page and AUR package (`lazypac`).

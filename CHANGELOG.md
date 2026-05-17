# Changelog

All notable changes to lazypac are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

---

## [1.3.0] - 2026-05-17

### Added
- `check-updates`: list all pending updates with old->new versions, major version bumps highlighted in bold red, and a summary count line. Uses `checkupdates` from `pacman-contrib`; falls back to `$PKG -Qu` against the local sync database if not found at runtime.
- `downgrade <pkg>`: list cached versions of a package from `/var/cache/pacman/pkg/`, prompt for selection, and install the chosen version via `sudo pacman -U`. After a successful install, prompts whether to add the package to IgnorePkg. Only one package at a time.
- `ignore <pkg...>`: add one or more packages to `IgnorePkg` in `/etc/pacman.conf` to prevent them from being upgraded. Creates the entry if absent.
- `unignore <pkg...>`: remove one or more packages from `IgnorePkg` in `/etc/pacman.conf` to allow upgrades again.

### Changed
- Script fully modularized into `lib/`: `packages.sh`, `cache.sh`, `query.sh`, `logs.sh`, `config.sh`, `help.sh`. `lazypac` is now a thin dispatcher that sources these modules and routes commands.
- `pacman-contrib` promoted from optional to required dependency; installs automatically with the package.

### Fixed
- `ignore` and `unignore` previously silently dropped all arguments after the first; both now iterate over all provided package names.
- `downgrade` with multiple arguments now exits with a clear error instead of silently ignoring extras.
- `ignore`/`unignore`: `sudo sed -i` failure (read-only filesystem, permission error) now reported explicitly instead of printing false success.
- `check-updates`: `checkupdates` exit code 1 (tool error) is now distinguished from exit code 2 (no updates); real errors are reported and exit 1 instead of printing "All packages are up to date."
- `orphans` and `remove-orphans`: removed `2>/dev/null` suppression so real errors from the package manager (db lock, corruption) are visible to the user.
- `safe-upgrade`: temp snapshot files in `/tmp` were not cleaned up on normal completion due to local variable scoping with `trap EXIT`; explicit cleanup added at end of function.

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

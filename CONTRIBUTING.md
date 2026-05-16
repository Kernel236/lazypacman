# Contributing to Lazy Pacman

Every kind of contribution is welcome — bug reports, new command ideas, documentation fixes, corrections to the man page, a better example in the README. No contribution is too small and none requires justification.

If you are new to AUR packaging, bash scripting, or open source in general, this is a good project to start with. Feel free to ask questions directly in an issue.

## Philosophy

Lazy Pacman is intentionally minimal. Before adding a feature, ask: does this stay true to the project philosophy?

- No databases, no state, no hidden logic
- Every command maps to exactly one underlying call
- The user always knows what is running underneath

A pull request that adds a complex feature with its own internal tracking will not be merged. A pull request that adds a clean alias for a useful pacman flag or combination of it probably will.

## Reporting a bug

Open a [GitHub issue](https://github.com/Kernel236/lazypacman/issues) and include:

- Your AUR helper (`yay` or `paru`) and its version
- The exact command you ran
- The output you got
- The output you expected

## Suggesting a command

Open an issue describing the new command, what it maps to underneath, and a real use case. If you are not sure whether it fits, open the issue anyway — worst case we figure out together why it does not fit, and that discussion might lead somewhere useful.

## Submitting a pull request

1. Fork the repo and create a branch from `main`.
2. Make your changes to `lazypac` and, if the command is new or changed, update `lazypac.1` and `README.md` to match.
3. Run ShellCheck locally before pushing:
   ```bash
   shellcheck lazypac
   ```
4. If you changed `PKGBUILD`, regenerate `.SRCINFO`:
   ```bash
   makepkg --printsrcinfo > .SRCINFO
   ```
5. Open the pull request. CI will run ShellCheck, the man page check, and namcap automatically.

Do not worry if something is not perfect — open the PR and we can iterate together.

## Style guide

- Indentation: 4 spaces (no tabs)
- Quote all variable expansions: `"$var"`, `"${var:-}"`
- No `set -e` — see the comment at the top of the script for why
- One command per `case` branch, keep it flat and readable
- New commands must have an entry in the `help` case, the man page, and the README table

## Code of Conduct

This project follows the values described in [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

# Security

## Scope

Lazy Pacman is a bash wrapper. It does not handle credentials, tokens, or network connections directly. Package operations are delegated entirely to `yay`, `paru`, or `pacman`, which have their own security models.

## Known risks and mitigations

**Temp files in `/tmp` (`safe-upgrade`)**
Temp files are created with `mktemp`, which generates a random name atomically. This prevents predictable-path symlink attacks. Files are removed via `trap ... EXIT` even if the command is interrupted.

**`remove-orphans` argument handling**
The orphan list is collected into a bash array with `mapfile` and expanded as `"${orphan_list[@]}"`. Each package name is a separate quoted word. No shell splitting or glob expansion on the list.

**Log directory**
`$XDG_DATA_HOME/lazypac/` is created with default user permissions (700). Only package names and versions are written there. No credentials or tokens.

## What is out of scope

- Vulnerabilities in `yay`, `paru`, `pacman`, or `pacdiff` — report those upstream.
- Attacks that require write access to the user's home directory. The machine is already compromised at that point.
- Theoretical attacks with no realistic exploitation path.

## Reporting a vulnerability

If you find something exploitable in a realistic scenario, email **riccardo.delsignore01@gmail.com** before opening a public issue. Include the affected command, a concrete scenario, and a fix if you have one. Expect a response within a few days.

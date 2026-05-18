<p align="center">
  <img src="assets/banner_lazypacman.png" alt="Lazy Pacman" width="1000">
</p>

<p align="center">
  <a href="https://github.com/Kernel236/lazypacman/actions/workflows/ci.yml"><img src="https://github.com/Kernel236/lazypacman/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/Kernel236/lazypacman/stargazers"><img src="https://img.shields.io/github/stars/Kernel236/lazypacman?label=thanks%20for%20the%20%E2%AD%90&color=grey" alt="Stars"></a>
  <a href="https://aur.archlinux.org/packages/lazypac"><img src="https://img.shields.io/aur/version/lazypac" alt="AUR version"></a>
  <img src="https://img.shields.io/badge/made%20with-%E2%9D%A4-red" alt="Made with love">
</p>

A simple bash wrapper for common `pacman`/`yay`/`paru` commands. No databases, no tracking, no hidden logic, just readable aliases. You always know exactly what's running underneath.

Automatically detects your package manager at startup: `yay` first, then `paru`, then plain `pacman`. Write operations (`install`, `remove`, `upgrade`...) run with `sudo` automatically when falling back to pacman.

*For those who don't want to memorise flags and their combinations*

---

## Demo

**Daily maintenance workflow**

<p align="center">
  <img src="assets/demo_maintenance.gif" alt="lazypac maintenance demo">
</p>

**Package search, inspect, and install**

<p align="center">
  <img src="assets/demo_install.gif" alt="lazypac install demo">
</p>

---

## TUI 

For those who don't even want to remember lazypac commands: `lazypac-tui` groups all of them into explorable submenus. Zero mnemonic effort required.

<p align="center">
  <img src="assets/demo_tui.gif" alt="lazypac-tui demo">
</p>

No extra dependencies — just run `lazypac-tui`.

---

## Install

### Option 1 - AUR

```bash
yay -S lazypac
# or
paru -S lazypac
```

### Option 2 - Manual

```bash
sudo cp lazypac lazypac-tui /usr/local/bin/
sudo chmod +x /usr/local/bin/lazypac /usr/local/bin/lazypac-tui
sudo mkdir -p /usr/lib/lazypac
sudo cp lib/*.sh /usr/lib/lazypac/
sudo cp assets/lazypacman_tui_banner.sh /usr/lib/lazypac/tui_banner.sh
```

### Dependencies

| Package | Type | Required for |
|---|---|---|
| `pacman-contrib` | required | `pactree` (`deps`), `paccache` (`cache-clean-old`), `checkupdates` (`check-updates`), `pacdiff` (suggested by `safe-upgrade` and `pacnew`) |
| `yay` or `paru` | optional | AUR support - falls back to plain `pacman` if neither is found |

---

## Command Reference

### Package management

| Command | Description | Underlying call |
|---|---|---|
| `install <pkg...>` | Install one or more packages | `yay -S <pkg...>` |
| `remove <pkg...>` | Remove package(s) + orphan deps | `yay -Rs <pkg...>` |
| `purge <pkg...>` | Remove package(s) + config files | `yay -Rns <pkg...>` |
| `update` | Sync repositories | `yay -Sy` |
| `upgrade` | Upgrade all packages | `yay -Syu` |
| `safe-upgrade` | Upgrade + log + pacnew check | `yay -Syu` + snapshot |
| `downgrade <pkg>` | Install a cached older version | `sudo pacman -U <file>` |

### Upgrade control

| Command | Description | Underlying call |
|---|---|---|
| `ignore <pkg...>` | Pin package(s) - skip on upgrades | `/etc/pacman.conf` IgnorePkg |
| `unignore <pkg...>` | Unpin package(s) - allow upgrades again | `/etc/pacman.conf` IgnorePkg |
| `ignored` | List currently pinned packages | `/etc/pacman.conf` IgnorePkg |

> `downgrade` prompts whether to add the package to IgnorePkg after a successful install.

### Updates

| Command | Description | Underlying call |
|---|---|---|
| `check-updates` | List available updates without installing | `checkupdates` or `yay -Qu` |

> `check-updates` uses `checkupdates` (from `pacman-contrib`) for fresh results. If not found at runtime, it falls back to `$PKG -Qu` using the local sync database - run `lazypac update` first if the database may be stale. Major version bumps are highlighted.

### Query

| Command | Description | Underlying call |
|---|---|---|
| `search <pkg>` | Search for a package in the repositories | `yay -Ss <pkg>` |
| `info <pkg>` | Show package details | `yay -Si <pkg>` |
| `list` | List installed (names only) | `yay -Qq` |
| `installed` | List installed (names + versions) | `yay -Q` |
| `check <pkg...>` | Check if a package is installed | `yay -Q <pkg>` |
| `deps <pkg>` | Show package dependency tree | `pactree <pkg>` |
| `orphans` | List orphan packages | `yay -Qdt` |

### Pacnew / pacsave

After an upgrade, pacman may leave `.pacnew` (new default config) or `.pacsave` (backup of overwritten config) files in `/etc`. These commands help you find and resolve them.

| Command | Description | Underlying call |
|---|---|---|
| `pacnew` | Find `.pacnew` and `.pacsave` files | `find /etc -name *.pacnew ...` |

### Logs

`safe-upgrade` saves a log of every version change to `$XDG_DATA_HOME/lazypac/` (defaults to `~/.local/share/lazypac/`).

| Command | Description | Underlying call |
|---|---|---|
| `log` | List upgrade log files | `ls -lh ~/.local/share/lazypac/` |
| `log <file>` | Read a log file | `less ~/.local/share/lazypac/<file>` |
| `logclean` | Delete all upgrade logs | `find ... -name *.log -delete` |

### Cleanup

| Command | Description | Underlying call |
|---|---|---|
| `remove-orphans` | Remove all orphan packages | `yay -Rns $(yay -Qdtq)` |
| `cache-size` | Show package cache size and file count | `du -sh /var/cache/pacman/pkg/` |
| `cache-clean` | Keep only the latest version per package | `sudo pacman -Sc` |
| `cache-clean-old` | Remove cache of uninstalled packages | `sudo paccache -ruk0` |
| `cache-clean-all` | Remove the entire package cache | `sudo pacman -Scc` |

> `cache-clean-old` requires `paccache` from `pacman-contrib`. To keep a specific number of versions instead, use `paccache -rk 2` directly.

> The AUR helper shown (`yay`) reflects whichever is detected on your system at runtime. If `paru` is installed instead, all commands use `paru`. If neither is found, commands fall back to plain `pacman`.

---

## Daily usage examples

**Check what would be upgraded before committing to it:**

```bash
lazypac check-updates          # see all pending updates with major bumps highlighted
```

**Weekly maintenance: upgrade, check what changed, then clean the cache**

```bash
lazypac safe-upgrade
lazypac log                               # list saved upgrade logs
lazypac log upgrade_20260516_120000.log   # read what actually changed
lazypac remove-orphans                    # drop deps that are no longer needed
lazypac cache-clean                       # remove old cached package versions
```

**Before installing something new: search, inspect, check disk impact**

```bash
lazypac search neovim                # find available packages
lazypac info neovim                  # read description, deps, install size
lazypac check neovim                 # confirm it is not already installed
lazypac install neovim
```

**After a huge upgrade find leftover config files:**

```bash
lazypac pacnew                       # list any .pacnew / .pacsave in /etc
# if files are listed: sudo pacdiff
```

**Skip a package you are not ready to upgrade yet:**

```bash
lazypac safe-upgrade --ignore hyprland   # upgrade everything except hyprland
lazypac ignore hyprland                  # pin it in /etc/pacman.conf permanently
lazypac unignore hyprland                # unpin it when ready
```

**Downgrade a package from the local cache:**

```bash
lazypac downgrade firefox            # choose from cached versions, then optionally pin it
```

**Check and reclaim cache space:**

```bash
lazypac cache-size                   # see how much /var/cache/pacman/pkg/ weighs
lazypac cache-clean-old              # remove cached versions of packages you uninstalled
lazypac cache-clean                  # keep only the latest version of each installed package
lazypac cache-clean-all              # nuclear option - wipe the entire cache
```

---

## Non-goals

- **Not a pacman replacement.** lazypac is a thin alias layer; anything outside its command set goes straight to `yay`, `paru`, or `pacman` directly.
- **No lock or recovery management.** Database locks, partial upgrades, and rollbacks are out of scope - handle them with pacman as usual.
- **No AUR without an AUR helper.** With plain pacman, `install` and `search` only reach the official repositories.

---

## Flag passthrough and multiple packages

All extra arguments after the command are forwarded verbatim to the underlying tool. Multiple package names work the same way.

```bash
lazypac install firefox chromium vlc --noconfirm
# -> yay -S firefox chromium vlc --noconfirm

lazypac remove gimp inkscape
# -> yay -Rs gimp inkscape

lazypac upgrade --devel
# -> yay -Syu --devel

lazypac safe-upgrade --devel
# -> yay -Syu --devel  (with before/after version logging)
```

---

## safe-upgrade log format

```
Lazy Pacman - upgrade log
Date: Fri May 16 12:00:00 UTC 2026
AUR helper: yay

  firefox                                  130.0-1  ->  131.0-1
  linux                                    6.9.1.arch1-1  ->  6.9.3.arch1-1
  python                                   3.12.3-1  ->  3.12.4-1
  some-aur-package                         (new install)  1.2.3-1
```

---

## Project structure

```
lazypac              # main entry point - detects pkg manager, sources modules, dispatches commands
lazypac-tui          # optional interactive TUI frontend (arrow-key menus, no extra deps)
lib/
  help.sh            # cmd_help()
  packages.sh        # install, remove, purge, update, upgrade, downgrade, remove-orphans
  cache.sh           # cache-clean, cache-clean-all, cache-clean-old, cache-size
  query.sh           # search, info, list, installed, check, deps, orphans, check-updates
  logs.sh            # safe-upgrade, log, logclean, pacnew
  config.sh          # ignore, unignore, ignored + IgnorePkg helpers
```

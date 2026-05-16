<p align="center">
  <img src="assets/banner_lazypacman.png" alt="Lazy Pacman" width="700">
</p>

A dead-simple bash wrapper for common `pacman`/`yay`/`paru` commands. No databases, no tracking, no hidden logic, just readable aliases. You always know exactly what's running underneath.

Automatically detects your AUR helper (`yay` preferred, then `paru`) at startup.

---

## Install

### Option 1 — Manual

```bash
sudo cp lazypac /usr/local/bin/
sudo chmod +x /usr/local/bin/lazypac
```

### Option 2 — AUR

```bash
yay -S lazypac
# or
paru -S lazypac
```

### Optional dependencies

| Package | Required for |
|---|---|
| `yay` or `paru` | any command (one of them is mandatory) |
| `pacman-contrib` | `sudo pacdiff` (suggested by `safe-upgrade` and `pacnew` when files are found) |

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

### Query

| Command | Description | Underlying call |
|---|---|---|
| `search <pkg>` | Search for a package | `yay -Ss <pkg>` |
| `info <pkg>` | Show package details | `yay -Si <pkg>` |
| `list` | List installed (names only) | `yay -Qq` |
| `installed` | List installed (names + versions) | `yay -Q` |
| `check <pkg>` | Check if a package is installed | `yay -Q <pkg>` |
| `deps <pkg>` | Show package dependency tree | `pactree <pkg>` |
| `orphans` | List orphan packages | `yay -Qdt` |

### Pacnew / pacsave

After an upgrade, pacman may leave `.pacnew` (new default config) or `.pacsave` (backup of overwritten config) files in `/etc`. These commands help you find and resolve them.

| Command | Description | Underlying call |
|---|---|---|
| `pacnew` | Find `.pacnew` and `.pacsave` files | `find /etc -name *.pacnew …` |

### Logs

`safe-upgrade` saves a log of every version change to `$XDG_DATA_HOME/lazypac/` (defaults to `~/.local/share/lazypac/`).

| Command | Description | Underlying call |
|---|---|---|
| `log` | List upgrade log files | `ls -lh ~/.local/share/lazypac/` |
| `log <file>` | Read a log file | `less ~/.local/share/lazypac/<file>` |
| `logclean` | Delete all upgrade logs | `find … -name *.log -delete` |

### Cleanup

| Command | Description | Underlying call |
|---|---|---|
| `remove-orphans` | Remove all orphan packages | `yay -Rns $(yay -Qdtq)` |
| `clean` | Remove old cached packages | `yay -Sc` |
| `clean-all` | Remove all cached packages | `yay -Scc` |

> The AUR helper shown (`yay`) reflects whichever is detected on your system at runtime. If `paru` is installed instead, all commands use `paru`.

---

## Flag passthrough and multiple packages

All extra arguments after the command are forwarded verbatim to the underlying tool. Multiple package names work the same way.

```bash
lazypac install firefox chromium vlc --noconfirm
# → yay -S firefox chromium vlc --noconfirm

lazypac remove gimp inkscape
# → yay -Rs gimp inkscape

lazypac upgrade --devel
# → yay -Syu --devel

lazypac safe-upgrade --devel
# → yay -Syu --devel  (with before/after version logging)
```

---

## safe-upgrade log format

```
Lazy Pacman — upgrade log
Date: Fri May 16 12:00:00 UTC 2026
AUR helper: yay

Updated packages:

  firefox                                  130.0-1  →  131.0-1
  linux                                    6.9.1.arch1-1  →  6.9.3.arch1-1
  python                                   3.12.3-1  →  3.12.4-1
  some-aur-package                         (new install)  1.2.3-1
```

---

## AUR Publish Instructions (Maintainer)

1. Cut a GitHub release and get the real tarball checksum:
   ```bash
   # After pushing the tag and letting GitHub generate the tarball:
   makepkg -g >> PKGBUILD   # replaces sha256sums=('SKIP') with the real hash
   ```

2. Regenerate `.SRCINFO` — required every time PKGBUILD changes:
   ```bash
   makepkg --printsrcinfo > .SRCINFO
   ```

3. Build and test locally:
   ```bash
   makepkg -si
   ```

4. Validate with namcap (must pass with no errors, warnings are worth reading):
   ```bash
   namcap PKGBUILD
   namcap lazypac-*.pkg.tar.zst
   ```

5. Publish to the AUR (both PKGBUILD and .SRCINFO must be committed):
   ```bash
   aurpublish lazypac
   ```

> `.SRCINFO` is what the AUR actually indexes. If it is missing or out of sync with PKGBUILD, the package will not appear in search results or will show wrong metadata.

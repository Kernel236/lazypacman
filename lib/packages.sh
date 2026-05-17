#!/usr/bin/env bash

cmd_install() {
    [[ -z "${1:-}" ]] && { echo "Usage: lazypac install <package...>"; exit 1; }
    pkg_write -S "$@"
}

cmd_remove() {
    [[ -z "${1:-}" ]] && { echo "Usage: lazypac remove <package...>"; exit 1; }
    pkg_write -Rs "$@"
}

cmd_purge() {
    [[ -z "${1:-}" ]] && { echo "Usage: lazypac purge <package...>"; exit 1; }
    pkg_write -Rns "$@"
}

cmd_update() {
    echo "WARNING: syncing repos without upgrading (-Sy) can leave the system in a partial upgrade state."
    echo "         This is unsafe on Arch Linux. Use 'lazypac upgrade' to sync and upgrade together."
    echo ""
    local _confirm
    read -r -p "Proceed anyway? [y/N] " _confirm
    [[ "$_confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
    pkg_write -Sy "$@"
}

cmd_upgrade() {
    pkg_write -Syu "$@"
}

cmd_downgrade() {
    [[ -z "${1:-}" ]] && { echo "Usage: lazypac downgrade <package>"; exit 1; }
    [[ -n "${2:-}" ]] && { echo "Usage: lazypac downgrade <package>"; echo "Only one package can be downgraded at a time."; exit 1; }
    local _pkg="${1}"
    local _cache_dir="${_LAZYPAC_CACHE_DIR:-/var/cache/pacman/pkg/}"
    local -a _candidates
    mapfile -t _candidates < <(find "$_cache_dir" -maxdepth 1 -name "${_pkg}-[0-9]*.pkg.tar.*" 2>/dev/null | sort -rV)
    if [[ ${#_candidates[@]} -eq 0 ]]; then
        echo "No cached versions of '$_pkg' found in $_cache_dir"
        exit 1
    fi
    echo "Cached versions of '$_pkg':"
    local i
    for i in "${!_candidates[@]}"; do
        printf "  [%d] %s\n" "$((i+1))" "$(basename "${_candidates[$i]}")"
    done
    echo ""
    local _sel
    read -r -p "Select version [1-${#_candidates[@]}]: " _sel
    if ! [[ "$_sel" =~ ^[0-9]+$ ]] || (( _sel < 1 || _sel > ${#_candidates[@]} )); then
        echo "Aborted."
        exit 1
    fi
    sudo pacman -U "${_candidates[$((_sel-1))]}" || exit 1
    echo ""
    local _ig_confirm
    read -r -p "Add '$_pkg' to IgnorePkg to prevent future upgrades? [y/N] " _ig_confirm
    if [[ "$_ig_confirm" =~ ^[Yy]$ ]]; then
        _lazypac_add_ignorepkg "$_pkg"
    fi
}

cmd_remove_orphans() {
    local -a orphan_list
    mapfile -t orphan_list < <("$PKG" -Qdtq)
    if [[ ${#orphan_list[@]} -eq 0 ]]; then
        echo "No orphan packages found."
    else
        pkg_write -Rns "${orphan_list[@]}"
    fi
}

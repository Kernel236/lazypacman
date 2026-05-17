#!/usr/bin/env bash

cmd_cache_clean() {
    sudo pacman -Sc "$@"
}

cmd_cache_clean_all() {
    sudo pacman -Scc "$@"
}

cmd_cache_clean_old() {
    if ! command -v paccache &>/dev/null; then
        echo "paccache not found - install pacman-contrib"
        exit 1
    fi
    sudo paccache -ruk0 "$@"
}

cmd_cache_size() {
    local _cache_dir="${_LAZYPAC_CACHE_DIR:-/var/cache/pacman/pkg/}"
    if [[ ! -r "$_cache_dir" ]]; then
        echo "Cannot read $_cache_dir - try running with sudo"
        exit 1
    fi
    echo "Cache location : $_cache_dir"
    echo "Total size     : $(du -sh "$_cache_dir" 2>/dev/null | cut -f1)"
    echo "Cached files   : $(ls "$_cache_dir" 2>/dev/null | wc -l)"
}

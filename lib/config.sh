#!/usr/bin/env bash

_lazypac_add_ignorepkg() {
    local pkg="${1}"
    local conf="${_PACMAN_CONF:-/etc/pacman.conf}"
    local ig_count
    ig_count=$(grep -c "^IgnorePkg" "$conf" 2>/dev/null) || ig_count=0
    if (( ig_count > 1 )); then
        echo "Multiple IgnorePkg lines in $conf - edit it manually."
        return 1
    fi
    local current=""
    if (( ig_count == 1 )); then
        current=$(grep -m1 "^IgnorePkg" "$conf" | sed 's/^IgnorePkg *= *//' | sed 's/ *$//')
    fi
    local e
    for e in $current; do
        if [[ "$e" == "$pkg" ]]; then
            echo "'$pkg' is already in IgnorePkg."
            return 0
        fi
    done
    local new_val
    if [[ -z "$current" ]]; then
        new_val="$pkg"
    else
        new_val="$current $pkg"
    fi
    if (( ig_count == 0 )); then
        if ! grep -q "^\[options\]" "$conf" 2>/dev/null; then
            echo "Cannot find [options] section in $conf - edit it manually."
            return 1
        fi
        sudo sed -i "/^\[options\]/a IgnorePkg = $pkg" "$conf" \
            || { echo "Failed to write to $conf."; return 1; }
    else
        sudo sed -i "s/^IgnorePkg *=.*/IgnorePkg = $new_val/" "$conf" \
            || { echo "Failed to write to $conf."; return 1; }
    fi
    echo "'$pkg' added to IgnorePkg."
}

_lazypac_rm_ignorepkg() {
    local pkg="${1}"
    local conf="${_PACMAN_CONF:-/etc/pacman.conf}"
    local ig_count
    ig_count=$(grep -c "^IgnorePkg" "$conf" 2>/dev/null) || ig_count=0
    if (( ig_count > 1 )); then
        echo "Multiple IgnorePkg lines in $conf - edit it manually."
        return 1
    fi
    if (( ig_count == 0 )); then
        echo "'$pkg' is not in IgnorePkg."
        return 1
    fi
    local current
    current=$(grep -m1 "^IgnorePkg" "$conf" | sed 's/^IgnorePkg *= *//' | sed 's/ *$//')
    local found=0
    local -a new=()
    local e
    for e in $current; do
        if [[ "$e" == "$pkg" ]]; then
            found=1
        else
            new+=("$e")
        fi
    done
    if (( found == 0 )); then
        echo "'$pkg' is not in IgnorePkg."
        return 1
    fi
    local new_val
    if (( ${#new[@]} == 0 )); then
        new_val=""
    else
        new_val="${new[*]}"
    fi
    sudo sed -i "s/^IgnorePkg *=.*/IgnorePkg = $new_val/" "$conf" \
        || { echo "Failed to write to $conf."; return 1; }
    echo "'$pkg' removed from IgnorePkg."
}

cmd_ignore() {
    [[ -z "${1:-}" ]] && { echo "Usage: lazypac ignore <package...>"; exit 1; }
    local pkg
    for pkg in "$@"; do
        _lazypac_add_ignorepkg "$pkg" || exit 1
    done
}

cmd_unignore() {
    [[ -z "${1:-}" ]] && { echo "Usage: lazypac unignore <package...>"; exit 1; }
    local pkg
    for pkg in "$@"; do
        _lazypac_rm_ignorepkg "$pkg" || exit 1
    done
}

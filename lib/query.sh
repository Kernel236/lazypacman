#!/usr/bin/env bash

cmd_search() {
    [[ -z "${1:-}" ]] && { echo "Usage: lazypac search <term>"; exit 1; }
    "$PKG" -Ss "$@"
}

cmd_info() {
    [[ -z "${1:-}" ]] && { echo "Usage: lazypac info <package>"; exit 1; }
    "$PKG" -Si "$@"
}

cmd_list() {
    "$PKG" -Qq
}

cmd_installed() {
    "$PKG" -Q
}

cmd_check() {
    [[ -z "${1:-}" ]] && { echo "Usage: lazypac check <package...>"; exit 1; }
    local _check_failed=0
    local pkgname
    for pkgname in "$@"; do
        if "$PKG" -Q "$pkgname" &>/dev/null; then
            echo "$pkgname: installed"
        else
            echo "$pkgname: not installed"
            _check_failed=1
        fi
    done
    exit "$_check_failed"
}

cmd_deps() {
    [[ -z "${1:-}" ]] && { echo "Usage: lazypac deps <package>"; exit 1; }
    if ! command -v pactree &>/dev/null; then
        echo "pactree not found - install pacman-contrib"
        exit 1
    fi
    pactree "$@"
}

cmd_orphans() {
    if ! "$PKG" -Qdt; then
        echo "No orphan packages."
    fi
}

cmd_check_updates() {
    local _cu_source _updates _cu_exit
    if command -v checkupdates &>/dev/null; then
        _cu_source="checkupdates"
        _updates=$(checkupdates 2>/dev/null)
        _cu_exit=$?
        # checkupdates: exit 0 = updates found, exit 2 = no updates, exit 1 = error
        if [[ -z "$_updates" && "$_cu_exit" -eq 1 ]]; then
            echo "checkupdates failed - the package database may be locked or inaccessible."
            exit 1
        fi
    else
        _cu_source="$PKG -Qu (local db - run 'lazypac update' first for fresh results)"
        _updates=$("$PKG" -Qu 2>/dev/null)
    fi

    if [[ -z "$_updates" ]]; then
        echo "All packages are up to date."
        exit 0
    fi

    local _red _reset
    if [[ -t 1 ]]; then
        _red=$(tput bold; tput setaf 1)
        _reset=$(tput sgr0)
    else
        _red=""
        _reset=""
    fi

    echo "Pending updates  (via $_cu_source)"
    echo ""

    local _major_count=0 _other_count=0 _total=0
    local _line _pkg _old _new _old_base _new_base _old_maj _new_maj

    while IFS= read -r _line; do
        [[ -z "$_line" ]] && continue
        _pkg=$(awk '{print $1}' <<< "$_line")
        _old=$(awk '{print $2}' <<< "$_line")
        _new=$(awk '{print $4}' <<< "$_line")

        _old_base=${_old#*:}; _old_base=${_old_base%-*}
        _new_base=${_new#*:}; _new_base=${_new_base%-*}

        _old_maj=$(cut -d. -f1 <<< "$_old_base")
        _new_maj=$(cut -d. -f1 <<< "$_new_base")

        if [[ "$_old_maj" =~ ^[0-9]+$ && "$_new_maj" =~ ^[0-9]+$ && "$_old_maj" -ne "$_new_maj" ]]; then
            printf "  %s[!] %-30s %-20s ->  %s%s\n" \
                "$_red" "$_pkg" "$_old" "$_new" "$_reset"
            _major_count=$(( _major_count + 1 ))
        else
            printf "      %-30s %-20s ->  %s\n" "$_pkg" "$_old" "$_new"
            _other_count=$(( _other_count + 1 ))
        fi
        _total=$(( _total + 1 ))
    done <<< "$_updates"

    echo ""
    printf "  %d update(s) available  |  %d major  |  %d other\n" \
        "$_total" "$_major_count" "$_other_count"
}

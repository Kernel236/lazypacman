#!/usr/bin/env bash

cmd_safe_upgrade() {
    local timestamp before_snap after_snap log_file
    timestamp=$(date +"%Y%m%d_%H%M%S")
    before_snap=$(mktemp /tmp/lazypac_before_XXXXXX)
    after_snap=$(mktemp /tmp/lazypac_after_XXXXXX)
    log_file="${LOG_DIR}/upgrade_${timestamp}.log"

    trap 'rm -f "$before_snap" "$after_snap"' EXIT

    echo "==> Snapshotting installed packages..."
    "$PKG" -Q > "$before_snap" || { echo "==> Failed to snapshot packages. Aborting."; exit 1; }

    echo "==> Running upgrade..."
    pkg_write -Syu "$@" || { echo "==> Upgrade failed. No log written."; exit 1; }

    echo ""
    echo "==> Snapshotting new state..."
    "$PKG" -Q > "$after_snap"

    echo "==> Generating upgrade log..."
    {
        echo "Lazy Pacman - upgrade log"
        echo "Date: $(date)"
        echo "AUR helper: $PKG"
        echo ""
        local changed=0
        local p new_ver old_ver
        while IFS=' ' read -r p new_ver; do
            old_ver=$(awk -v name="$p" '$1==name{print $2}' "$before_snap")
            if [[ -z "$old_ver" ]]; then
                printf "  %-40s (new install)  %s\n" "$p" "$new_ver"
                changed=1
            elif [[ "$old_ver" != "$new_ver" ]]; then
                printf "  %-40s %s  ->  %s\n" "$p" "$old_ver" "$new_ver"
                changed=1
            fi
        done < "$after_snap"
        if [[ "$changed" -eq 0 ]]; then
            echo "  Nothing was updated."
        fi
    } | tee "$log_file"

    echo ""
    echo "Log saved to: $log_file"

    local pacnew_found
    pacnew_found=$(find /etc \( -name "*.pacnew" -o -name "*.pacsave" \) 2>/dev/null)
    if [[ -n "$pacnew_found" ]]; then
        echo ""
        echo "==> .pacnew/.pacsave files found - review them with:"
        echo "      sudo pacdiff"
        echo ""
        echo "$pacnew_found"
    fi

    rm -f "$before_snap" "$after_snap"
}

cmd_log() {
    if [[ -z "${1:-}" ]]; then
        if [[ -z "$(ls -A "$LOG_DIR" 2>/dev/null)" ]]; then
            echo "No logs yet. Run 'lazypac safe-upgrade' to start logging."
        else
            ls -lh "$LOG_DIR"
        fi
    else
        [[ "$1" == */* ]] && { echo "Invalid log name."; exit 1; }
        local log_path="${LOG_DIR}/${1}"
        if [[ ! -f "$log_path" ]]; then
            echo "Log file not found: ${1}"
            echo "Run 'lazypac log' to list available logs."
            exit 1
        fi
        less "$log_path"
    fi
}

cmd_logclean() {
    local count
    count=$(find "$LOG_DIR" -name "*.log" 2>/dev/null | wc -l)
    if [[ "$count" -eq 0 ]]; then
        echo "No log files to remove."
    else
        echo "Removing $count log file(s) from $LOG_DIR..."
        find "$LOG_DIR" -name "*.log" -delete
        echo "Done."
    fi
}

cmd_pacnew() {
    echo "Searching for .pacnew and .pacsave files..."
    local found
    found=$(find /etc \( -name "*.pacnew" -o -name "*.pacsave" \) 2>/dev/null)
    if [[ -z "$found" ]]; then
        echo "No .pacnew or .pacsave files found."
    else
        echo "$found"
        echo ""
        echo "To review and merge them: sudo pacdiff"
    fi
}

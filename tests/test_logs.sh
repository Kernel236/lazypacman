#!/usr/bin/env bats

load helpers

# ---------------------------------------------------------------------------
# log
# ---------------------------------------------------------------------------

@test "log with empty log dir prints hint to run safe-upgrade" {
    run bash "$LAZYPAC" log
    [ "$status" -eq 0 ]
    [[ "$output" == *"No logs yet"* ]]
}

@test "log with missing filename exits 1 with message" {
    run bash "$LAZYPAC" log nonexistent.log
    [ "$status" -eq 1 ]
    [[ "$output" == *"Log file not found: nonexistent.log"* ]]
}

@test "log with existing filename shows its content" {
    echo "upgrade entry" > "$XDG_DATA_HOME/lazypac/upgrade_20260516_120000.log"
    run bash "$LAZYPAC" log upgrade_20260516_120000.log
    [ "$status" -eq 0 ]
    [[ "$output" == *"upgrade entry"* ]]
}

# ---------------------------------------------------------------------------
# logclean
# ---------------------------------------------------------------------------

@test "logclean with no logs prints message" {
    run bash "$LAZYPAC" logclean
    [ "$status" -eq 0 ]
    [ "$output" = "No log files to remove." ]
}

@test "logclean removes all log files and reports count" {
    touch "$XDG_DATA_HOME/lazypac/upgrade_a.log"
    touch "$XDG_DATA_HOME/lazypac/upgrade_b.log"
    touch "$XDG_DATA_HOME/lazypac/upgrade_c.log"
    run bash "$LAZYPAC" logclean
    [ "$status" -eq 0 ]
    [[ "$output" == *"Removing 3 log file(s)"* ]]
    [[ "$output" == *"Done."* ]]
    [ "$(find "$XDG_DATA_HOME/lazypac" -name "*.log" | wc -l)" -eq 0 ]
}

# ---------------------------------------------------------------------------
# safe-upgrade
# ---------------------------------------------------------------------------

@test "safe-upgrade exits 0 and creates a log file" {
    run bash "$LAZYPAC" safe-upgrade
    [ "$status" -eq 0 ]
    [ "$(find "$XDG_DATA_HOME/lazypac" -name "*.log" | wc -l)" -eq 1 ]
}

@test "safe-upgrade records nothing-updated when versions are unchanged" {
    run bash "$LAZYPAC" safe-upgrade
    [ "$status" -eq 0 ]
    [[ "$output" == *"Nothing was updated"* ]]
}

@test "safe-upgrade passes extra flags to yay -Syu" {
    run bash "$LAZYPAC" safe-upgrade --devel
    [ "$status" -eq 0 ]
    [[ "$output" == *"yay -Syu --devel"* ]]
}

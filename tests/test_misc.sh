#!/usr/bin/env bats

load helpers

# ---------------------------------------------------------------------------
# AUR helper detection
# ---------------------------------------------------------------------------

@test "exits 1 with message when no AUR helper is found" {
    run env PATH="/usr/bin:/bin" bash "$LAZYPAC" version
    [ "$status" -eq 1 ]
    [[ "$output" == *"No package manager found"* ]]
}

# ---------------------------------------------------------------------------
# version
# ---------------------------------------------------------------------------

@test "version prints version string" {
    run bash "$LAZYPAC" version
    [ "$status" -eq 0 ]
    [ "$output" = "lazypac 1.4.0" ]
}

@test "--version prints version string" {
    run bash "$LAZYPAC" --version
    [ "$status" -eq 0 ]
    [ "$output" = "lazypac 1.4.0" ]
}

@test "-v prints version string" {
    run bash "$LAZYPAC" -v
    [ "$status" -eq 0 ]
    [ "$output" = "lazypac 1.4.0" ]
}

# ---------------------------------------------------------------------------
# Unknown / no command
# ---------------------------------------------------------------------------

@test "no command exits 1 and suggests help" {
    run bash "$LAZYPAC"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown command"* ]]
    [[ "$output" == *"lazypac help"* ]]
}

@test "unknown command exits 1 with command name in message" {
    run bash "$LAZYPAC" foobar
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown command: 'foobar'"* ]]
}

# ---------------------------------------------------------------------------
# help
# ---------------------------------------------------------------------------

@test "help exits 0 and lists all command categories" {
    run bash "$LAZYPAC" help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Package management"* ]]
    [[ "$output" == *"safe-upgrade"* ]]
    [[ "$output" == *"downgrade"* ]]
    [[ "$output" == *"ignore"* ]]
    [[ "$output" == *"check-updates"* ]]
    [[ "$output" == *"Pacnew"* ]]
    [[ "$output" == *"Logs"* ]]
}

@test "--help exits 0" {
    run bash "$LAZYPAC" --help
    [ "$status" -eq 0 ]
}

@test "-h exits 0" {
    run bash "$LAZYPAC" -h
    [ "$status" -eq 0 ]
}

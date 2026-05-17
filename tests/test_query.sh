#!/usr/bin/env bats

load helpers

# ---------------------------------------------------------------------------
# search / info
# ---------------------------------------------------------------------------

@test "search passes term to yay -Ss" {
    run bash "$LAZYPAC" search neovim
    [ "$status" -eq 0 ]
    [ "$output" = "yay -Ss neovim" ]
}

@test "info passes package to yay -Si" {
    run bash "$LAZYPAC" info neovim
    [ "$status" -eq 0 ]
    [ "$output" = "yay -Si neovim" ]
}

# ---------------------------------------------------------------------------
# list / installed
# ---------------------------------------------------------------------------

@test "list outputs package names" {
    run bash "$LAZYPAC" list
    [ "$status" -eq 0 ]
    [[ "$output" == *"git"* ]]
    [[ "$output" == *"firefox"* ]]
}

@test "installed outputs names and versions" {
    run bash "$LAZYPAC" installed
    [ "$status" -eq 0 ]
    [[ "$output" == *"git 1.0.0"* ]]
    [[ "$output" == *"firefox 1.0.0"* ]]
}

# ---------------------------------------------------------------------------
# check
# ---------------------------------------------------------------------------

@test "check with no argument exits 1 and prints usage" {
    run bash "$LAZYPAC" check
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: lazypac check"* ]]
}

@test "check reports installed for a known package" {
    run bash "$LAZYPAC" check git
    [ "$status" -eq 0 ]
    [ "$output" = "git: installed" ]
}

@test "check reports not installed for an unknown package and exits 1" {
    run bash "$LAZYPAC" check nonexistent-pkg
    [ "$status" -eq 1 ]
    [ "$output" = "nonexistent-pkg: not installed" ]
}

@test "check handles mixed results and exits 1 when any package is missing" {
    run bash "$LAZYPAC" check git nonexistent-pkg firefox
    [ "$status" -eq 1 ]
    [[ "$output" == *"git: installed"* ]]
    [[ "$output" == *"nonexistent-pkg: not installed"* ]]
    [[ "$output" == *"firefox: installed"* ]]
}

# ---------------------------------------------------------------------------
# pacnew
# ---------------------------------------------------------------------------

@test "pacnew exits 0" {
    run bash "$LAZYPAC" pacnew
    [ "$status" -eq 0 ]
}

@test "pacnew reports no files or lists them" {
    run bash "$LAZYPAC" pacnew
    [ "$status" -eq 0 ]
    [[ "$output" == *"No .pacnew"* ]] || [[ "$output" == *".pacnew"* ]]
}

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

# ---------------------------------------------------------------------------
# check-updates
# ---------------------------------------------------------------------------

@test "check-updates reports up to date when no updates available" {
    run bash "$LAZYPAC" check-updates
    [ "$status" -eq 0 ]
    [[ "$output" == *"up to date"* ]]
}

@test "check-updates lists a minor update without major marker" {
    export FAKE_UPDATES="curl 8.8.0-1 -> 8.9.0-1"
    run bash "$LAZYPAC" check-updates
    [ "$status" -eq 0 ]
    [[ "$output" == *"curl"* ]]
    [[ "$output" == *"8.8.0-1"* ]]
    [[ "$output" == *"8.9.0-1"* ]]
    [[ "$output" != *"[!]"* ]]
}

@test "check-updates marks a major version bump with [!]" {
    export FAKE_UPDATES="firefox 128.0-1 -> 129.0-1"
    run bash "$LAZYPAC" check-updates
    [ "$status" -eq 0 ]
    [[ "$output" == *"[!]"* ]]
    [[ "$output" == *"firefox"* ]]
}

@test "check-updates summary line shows correct totals" {
    export FAKE_UPDATES="$(printf 'firefox 128.0-1 -> 129.0-1\ncurl 8.8.0-1 -> 8.9.0-1')"
    run bash "$LAZYPAC" check-updates
    [ "$status" -eq 0 ]
    [[ "$output" == *"2 update(s) available"* ]]
    [[ "$output" == *"1 major"* ]]
    [[ "$output" == *"1 other"* ]]
}

@test "check-updates handles epoch versions without misclassifying" {
    export FAKE_UPDATES="libfoo 2:1.5.0-1 -> 2:1.6.0-1"
    run bash "$LAZYPAC" check-updates
    [ "$status" -eq 0 ]
    [[ "$output" != *"[!]"* ]]
}

@test "check-updates falls back to PKG -Qu when checkupdates not available" {
    rm "$BATS_TEST_TMPDIR/bin/checkupdates"
    export FAKE_UPDATES="git 2.45.0-1 -> 2.45.1-1"
    run bash "$LAZYPAC" check-updates
    [ "$status" -eq 0 ]
    [[ "$output" == *"git"* ]]
    [[ "$output" == *"local db"* ]]
}

@test "check-updates uses checkupdates when available" {
    export FAKE_UPDATES="git 2.45.0-1 -> 2.45.1-1"
    run bash "$LAZYPAC" check-updates
    [ "$status" -eq 0 ]
    [[ "$output" == *"checkupdates"* ]]
}

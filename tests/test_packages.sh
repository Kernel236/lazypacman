#!/usr/bin/env bats

load helpers

# ---------------------------------------------------------------------------
# install
# ---------------------------------------------------------------------------

@test "install passes single package to yay -S" {
    run bash "$LAZYPAC" install firefox
    [ "$status" -eq 0 ]
    [ "$output" = "yay -S firefox" ]
}

@test "install passes multiple packages and flags" {
    run bash "$LAZYPAC" install firefox chromium vlc --noconfirm
    [ "$status" -eq 0 ]
    [ "$output" = "yay -S firefox chromium vlc --noconfirm" ]
}

# ---------------------------------------------------------------------------
# remove / purge
# ---------------------------------------------------------------------------

@test "remove passes package to yay -Rs" {
    run bash "$LAZYPAC" remove gimp
    [ "$status" -eq 0 ]
    [ "$output" = "yay -Rs gimp" ]
}

@test "remove passes multiple packages" {
    run bash "$LAZYPAC" remove gimp inkscape krita
    [ "$status" -eq 0 ]
    [ "$output" = "yay -Rs gimp inkscape krita" ]
}

@test "purge passes package to yay -Rns" {
    run bash "$LAZYPAC" purge openssh
    [ "$status" -eq 0 ]
    [ "$output" = "yay -Rns openssh" ]
}

# ---------------------------------------------------------------------------
# update / upgrade
# ---------------------------------------------------------------------------

@test "update calls yay -Sy" {
    run bash "$LAZYPAC" update
    [ "$status" -eq 0 ]
    [ "$output" = "yay -Sy" ]
}

@test "upgrade calls yay -Syu" {
    run bash "$LAZYPAC" upgrade
    [ "$status" -eq 0 ]
    [[ "$output" == *"yay -Syu"* ]]
}

@test "upgrade passes extra flags through" {
    run bash "$LAZYPAC" upgrade --devel --noconfirm
    [ "$status" -eq 0 ]
    [[ "$output" == *"yay -Syu --devel --noconfirm"* ]]
}

# ---------------------------------------------------------------------------
# clean
# ---------------------------------------------------------------------------

@test "clean calls yay -Sc" {
    run bash "$LAZYPAC" clean
    [ "$status" -eq 0 ]
    [ "$output" = "yay -Sc" ]
}

@test "clean-all calls yay -Scc" {
    run bash "$LAZYPAC" clean-all
    [ "$status" -eq 0 ]
    [ "$output" = "yay -Scc" ]
}

# ---------------------------------------------------------------------------
# remove-orphans
# ---------------------------------------------------------------------------

@test "remove-orphans prints message when no orphans exist" {
    run bash "$LAZYPAC" remove-orphans
    [ "$status" -eq 0 ]
    [ "$output" = "No orphan packages found." ]
}

@test "remove-orphans calls yay -Rns when orphans exist" {
    export FAKE_ORPHANS="oldlib oldtool"
    run bash "$LAZYPAC" remove-orphans
    unset FAKE_ORPHANS
    [ "$status" -eq 0 ]
    [[ "$output" == *"yay -Rns"* ]]
    [[ "$output" == *"oldlib"* ]]
    [[ "$output" == *"oldtool"* ]]
}

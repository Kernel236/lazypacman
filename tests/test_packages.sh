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

@test "update prints warning and runs -Sy when confirmed with y" {
    run bash -c "echo 'y' | bash '$LAZYPAC' update"
    [ "$status" -eq 0 ]
    [[ "$output" == *"WARNING"* ]]
    [[ "$output" == *"yay -Sy"* ]]
}

@test "update aborts when not confirmed" {
    run bash -c "echo 'n' | bash '$LAZYPAC' update"
    [ "$status" -eq 1 ]
    [[ "$output" == *"WARNING"* ]]
    [[ "$output" == *"Aborted"* ]]
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

@test "cache-clean calls pacman -Sc" {
    run bash "$LAZYPAC" cache-clean
    [ "$status" -eq 0 ]
    [[ "$output" == *"pacman -Sc"* ]]
}

@test "cache-clean-all calls pacman -Scc" {
    run bash "$LAZYPAC" cache-clean-all
    [ "$status" -eq 0 ]
    [[ "$output" == *"pacman -Scc"* ]]
}

@test "cache-clean-old calls paccache -ruk0" {
    run bash "$LAZYPAC" cache-clean-old
    [ "$status" -eq 0 ]
    [[ "$output" == *"paccache"* ]]
    [[ "$output" == *"-ruk0"* ]]
}

@test "cache-size prints cache location and size" {
    mkdir -p "$BATS_TEST_TMPDIR/pkg"
    export _LAZYPAC_CACHE_DIR="$BATS_TEST_TMPDIR/pkg"
    run bash "$LAZYPAC" cache-size
    [ "$status" -eq 0 ]
    [[ "$output" == *"Cache location"* ]]
    [[ "$output" == *"Total size"* ]]
    [[ "$output" == *"Cached files"* ]]
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

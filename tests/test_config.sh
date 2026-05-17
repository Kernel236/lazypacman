#!/usr/bin/env bats

load helpers

# ---------------------------------------------------------------------------
# ignore
# ---------------------------------------------------------------------------

@test "ignore without argument exits 1 with usage" {
    run bash "$LAZYPAC" ignore
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: lazypac ignore"* ]]
}

@test "ignore adds multiple packages in one call" {
    run bash "$LAZYPAC" ignore firefox chromium
    [ "$status" -eq 0 ]
    grep -q "^IgnorePkg = firefox chromium" "$_PACMAN_CONF"
}

@test "ignore creates IgnorePkg line when none exists" {
    run bash "$LAZYPAC" ignore firefox
    [ "$status" -eq 0 ]
    [[ "$output" == *"added to IgnorePkg"* ]]
    grep -q "^IgnorePkg = firefox" "$_PACMAN_CONF"
}

@test "ignore appends to existing IgnorePkg line" {
    echo "IgnorePkg = chromium" >> "$_PACMAN_CONF"
    run bash "$LAZYPAC" ignore firefox
    [ "$status" -eq 0 ]
    grep -q "^IgnorePkg = chromium firefox" "$_PACMAN_CONF"
}

@test "ignore is idempotent when package already present" {
    echo "IgnorePkg = firefox" >> "$_PACMAN_CONF"
    run bash "$LAZYPAC" ignore firefox
    [ "$status" -eq 0 ]
    [[ "$output" == *"already in IgnorePkg"* ]]
    [ "$(grep -c "^IgnorePkg" "$_PACMAN_CONF")" -eq 1 ]
}

@test "ignore adds to empty IgnorePkg line" {
    echo "IgnorePkg =" >> "$_PACMAN_CONF"
    run bash "$LAZYPAC" ignore firefox
    [ "$status" -eq 0 ]
    grep -q "^IgnorePkg = firefox" "$_PACMAN_CONF"
}

# ---------------------------------------------------------------------------
# unignore
# ---------------------------------------------------------------------------

@test "unignore without argument exits 1 with usage" {
    run bash "$LAZYPAC" unignore
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: lazypac unignore"* ]]
}

@test "unignore removes multiple packages in one call" {
    echo "IgnorePkg = chromium firefox vlc" >> "$_PACMAN_CONF"
    run bash "$LAZYPAC" unignore firefox chromium
    [ "$status" -eq 0 ]
    grep -q "^IgnorePkg = vlc" "$_PACMAN_CONF"
}

@test "unignore exits 1 when IgnorePkg line is absent" {
    run bash "$LAZYPAC" unignore firefox
    [ "$status" -eq 1 ]
    [[ "$output" == *"not in IgnorePkg"* ]]
}

@test "unignore exits 1 when package is not in the list" {
    echo "IgnorePkg = chromium" >> "$_PACMAN_CONF"
    run bash "$LAZYPAC" unignore firefox
    [ "$status" -eq 1 ]
    [[ "$output" == *"not in IgnorePkg"* ]]
}

@test "unignore removes package from a multi-package list" {
    echo "IgnorePkg = chromium firefox vlc" >> "$_PACMAN_CONF"
    run bash "$LAZYPAC" unignore firefox
    [ "$status" -eq 0 ]
    [[ "$output" == *"removed from IgnorePkg"* ]]
    grep -q "^IgnorePkg = chromium vlc" "$_PACMAN_CONF"
}

@test "unignore leaves empty IgnorePkg line when last package is removed" {
    echo "IgnorePkg = firefox" >> "$_PACMAN_CONF"
    run bash "$LAZYPAC" unignore firefox
    [ "$status" -eq 0 ]
    grep -q "^IgnorePkg = $" "$_PACMAN_CONF"
}

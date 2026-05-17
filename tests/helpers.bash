LAZYPAC="$(dirname "$BATS_TEST_FILENAME")/../lazypac"

setup() {
    export XDG_DATA_HOME="$BATS_TEST_TMPDIR/data"
    mkdir -p "$BATS_TEST_TMPDIR/bin" "$XDG_DATA_HOME/lazypac"
    export PATH="$BATS_TEST_TMPDIR/bin:$PATH"

    # Fake AUR helper — simulates yay behaviour without touching the system
    cat > "$BATS_TEST_TMPDIR/bin/yay" << 'EOF'
#!/usr/bin/env bash
INSTALLED=(git firefox curl)
is_installed() { for p in "${INSTALLED[@]}"; do [[ "$p" == "$1" ]] && return 0; done; return 1; }
case "${1:-}" in
    -Q)
        if [[ -n "${2:-}" ]]; then
            is_installed "$2" && echo "$2 1.0.0" && exit 0 || exit 1
        else
            for p in "${INSTALLED[@]}"; do echo "$p 1.0.0"; done
        fi ;;
    -Qq)   printf "%s\n" "${INSTALLED[@]}" ;;
    -Qdt)  [[ -n "${FAKE_ORPHANS:-}" ]] && printf "%s\n" ${FAKE_ORPHANS} || exit 1 ;;
    -Qdtq) [[ -n "${FAKE_ORPHANS:-}" ]] && printf "%s\n" ${FAKE_ORPHANS} || true ;;
    -S)    echo "yay -S ${*:2}" ;;
    -Rs)   echo "yay -Rs ${*:2}" ;;
    -Rns)  echo "yay -Rns ${*:2}" ;;
    -Sy)   echo "yay -Sy" ;;
    -Syu)  echo "yay -Syu ${*:2}" ;;
    -Ss)   echo "yay -Ss ${*:2}" ;;
    -Si)   echo "yay -Si ${*:2}" ;;
    -Sc)   echo "yay -Sc" ;;
    -Scc)  echo "yay -Scc" ;;
    -Qu)
        if [[ -n "${FAKE_UPDATES:-}" ]]; then
            printf "%s\n" "$FAKE_UPDATES"
        fi ;;
esac
EOF
    chmod +x "$BATS_TEST_TMPDIR/bin/yay"

    # Fake sudo — passes through to the next command in the test environment
    cat > "$BATS_TEST_TMPDIR/bin/sudo" << 'EOF'
#!/usr/bin/env bash
exec "$@"
EOF
    chmod +x "$BATS_TEST_TMPDIR/bin/sudo"

    # Fake pacman — handles cache commands
    cat > "$BATS_TEST_TMPDIR/bin/pacman" << 'EOF'
#!/usr/bin/env bash
case "${1:-}" in
    -Sc)  echo "pacman -Sc ${*:2}" ;;
    -Scc) echo "pacman -Scc ${*:2}" ;;
    -Sy)  echo "pacman -Sy" ;;
    -Q)
        INSTALLED=(git firefox curl)
        if [[ -n "${2:-}" ]]; then
            for p in "${INSTALLED[@]}"; do [[ "$p" == "$2" ]] && echo "$2 1.0.0" && exit 0; done; exit 1
        else
            for p in "${INSTALLED[@]}"; do echo "$p 1.0.0"; done
        fi ;;
esac
EOF
    chmod +x "$BATS_TEST_TMPDIR/bin/pacman"

    # Fake paccache — handles cache-clean-old
    cat > "$BATS_TEST_TMPDIR/bin/paccache" << 'EOF'
#!/usr/bin/env bash
echo "paccache $*"
EOF
    chmod +x "$BATS_TEST_TMPDIR/bin/paccache"

    # Fake less — cats the file so output is capturable in tests
    cat > "$BATS_TEST_TMPDIR/bin/less" << 'EOF'
#!/usr/bin/env bash
cat "$1"
EOF
    chmod +x "$BATS_TEST_TMPDIR/bin/less"

    # Fake checkupdates (pacman-contrib) — returns FAKE_UPDATES content
    cat > "$BATS_TEST_TMPDIR/bin/checkupdates" << 'EOF'
#!/usr/bin/env bash
if [[ -n "${FAKE_UPDATES:-}" ]]; then
    printf "%s\n" "$FAKE_UPDATES"
fi
EOF
    chmod +x "$BATS_TEST_TMPDIR/bin/checkupdates"
}

# rutils dev environment for bash / Git Bash.
# Usage (from anywhere):   source rutils/env/activate.sh
# Leave it with:           deactivate_rutils
# Only affects the current terminal session.

RUTILS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUTILS_BIN="$RUTILS_ROOT/target/debug"

echo "rutils: building..."
if ! cargo build --quiet --manifest-path "$RUTILS_ROOT/Cargo.toml"; then
    echo "rutils: build failed, environment not activated" >&2
    return 1
fi

# Save state so deactivate can restore it
if [ -z "$RUTILS_ACTIVE" ]; then
    RUTILS_OLD_PATH="$PATH"
    RUTILS_OLD_PS1="$PS1"
fi
RUTILS_ACTIVE=1

# Put the freshly built binaries first on PATH
export PATH="$RUTILS_BIN:$RUTILS_OLD_PATH"
PS1="(rutils) $RUTILS_OLD_PS1"

# rcd prints the target dir; this wrapper actually moves the shell there
rcd() {
    local target
    target="$("$RUTILS_BIN/rcd" "$@")" && cd "$target"
}

rebuild_rutils() {
    cargo build --quiet --manifest-path "$RUTILS_ROOT/Cargo.toml"
}

deactivate_rutils() {
    export PATH="$RUTILS_OLD_PATH"
    PS1="$RUTILS_OLD_PS1"
    unset -f rcd rebuild_rutils deactivate_rutils
    unset RUTILS_ACTIVE RUTILS_OLD_PATH RUTILS_OLD_PS1 RUTILS_ROOT RUTILS_BIN
}

echo "rutils: active. Commands from $RUTILS_BIN. Run 'deactivate_rutils' to leave."

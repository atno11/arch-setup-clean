#!/usr/bin/env bash

PAWLETTE_REPO_URL="https://github.com/meowrch/pawlette.git"
PAWLETTE_SOURCE_DIR="$HOME/pawlette"
PAWLETTE_COMMIT="823e1c16304c812278ed27e05533008896a3ada7"

install_pawlette() {
    echo
    echo "==> Installing Pawlette..."

    if command -v pawlette >/dev/null 2>&1; then
        echo "==> Pawlette already installed."
        return
    fi

    if ! command -v pipx >/dev/null 2>&1; then
        echo "ERROR: pipx is not installed." >&2
        return 1
    fi

    if [[ -d "$PAWLETTE_SOURCE_DIR/.git" ]]; then
        echo "==> Pawlette source repository already present."
    elif [[ -e "$PAWLETTE_SOURCE_DIR" ]]; then
        echo "ERROR: $PAWLETTE_SOURCE_DIR exists but is not a Git repository." >&2
        return 1
    else
        echo "==> Cloning Pawlette..."

        git clone \
            "$PAWLETTE_REPO_URL" \
            "$PAWLETTE_SOURCE_DIR"
    fi

    echo "==> Checking out Pawlette commit:"
    echo "    $PAWLETTE_COMMIT"

    git -C "$PAWLETTE_SOURCE_DIR" fetch --all --tags

    git -C "$PAWLETTE_SOURCE_DIR" checkout \
        --detach \
        "$PAWLETTE_COMMIT"

    echo "==> Installing Pawlette with pipx..."

    pipx install \
        "$PAWLETTE_SOURCE_DIR"

    if ! command -v pawlette >/dev/null 2>&1; then
        echo "ERROR: Pawlette installation completed but the command is not available." >&2
        return 1
    fi

    echo "==> Pawlette installed successfully."
}

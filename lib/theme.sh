#!/usr/bin/env bash

PAWLETTE_THEME="catppuccin-mocha"

ensure_pawlette_config() {
    local config_dir="$HOME/.config/pawlette"
    local config_file="$config_dir/pawlette.json"

    if [[ -f "$config_file" ]]; then
        return
    fi

    echo "==> Generating Pawlette config..."

    mkdir -p "$config_dir"

    pawlette generate-config
}

install_theme() {
    echo
    echo "==> Configuring Pawlette theme..."

    if ! command -v pawlette >/dev/null 2>&1; then
        echo "ERROR: pawlette is not installed." >&2
        return 1
    fi

    ensure_pawlette_config

    if ! pawlette get-themes 2>/dev/null |
        tr ' ' '\n' |
        grep -Fxq "$PAWLETTE_THEME"; then

        echo "==> Installing Pawlette theme: $PAWLETTE_THEME"

        pawlette install-theme "$PAWLETTE_THEME"
    fi

    echo "==> Applying Pawlette theme: $PAWLETTE_THEME"

    pawlette set-theme "$PAWLETTE_THEME"
}

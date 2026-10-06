#!/usr/bin/env bash

AUDIO_CONFIG_FILE="$ROOT_DIR/config/audio.env"

VBAN_TEMPLATE="$DOTFILES_DIR/.config/pipewire/pipewire.conf.d/30-send.conf.template"
VBAN_SEND_FILE="$HOME/.config/pipewire/pipewire.conf.d/30-send.conf"

load_audio_config() {
    if [[ ! -f "$AUDIO_CONFIG_FILE" ]]; then
        echo "ERROR: Audio config not found: $AUDIO_CONFIG_FILE" >&2
        return 1
    fi

    # shellcheck disable=SC1090
    source "$AUDIO_CONFIG_FILE"

    if [[ -z "${VBAN_TARGET_IP:-}" ]]; then
        echo "ERROR: VBAN_TARGET_IP is not set." >&2
        return 1
    fi

    if [[ -z "${VBAN_TARGET_PORT:-}" ]]; then
        echo "ERROR: VBAN_TARGET_PORT is not set." >&2
        return 1
    fi

    if [[ ! "$VBAN_TARGET_PORT" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Invalid VBAN_TARGET_PORT: $VBAN_TARGET_PORT" >&2
        return 1
    fi
}

generate_vban_send_config() {
    if [[ ! -f "$VBAN_TEMPLATE" ]]; then
        echo "ERROR: VBAN template not found: $VBAN_TEMPLATE" >&2
        return 1
    fi

    local content

    content="$(<"$VBAN_TEMPLATE")"

    content="${content//@VBAN_TARGET_IP@/$VBAN_TARGET_IP}"
    content="${content//@VBAN_TARGET_PORT@/$VBAN_TARGET_PORT}"

    if [[ "$content" == *"@VBAN_TARGET_"* ]]; then
        echo "ERROR: Unresolved VBAN template variable." >&2
        return 1
    fi

    mkdir -p "$(dirname "$VBAN_SEND_FILE")"

    printf '%s\n' "$content" > "$VBAN_SEND_FILE"
}

configure_audio() {
    echo
    echo "==> Configuring PipeWire / VBAN..."

    load_audio_config
    generate_vban_send_config

    echo "    VBAN target: $VBAN_TARGET_IP:$VBAN_TARGET_PORT"
    echo "    Generated: $VBAN_SEND_FILE"
}

#!/usr/bin/env bash

DOTFILES_REPO_URL="https://github.com/atno11/dotfiles-clean.git"
DOTFILES_DIR="$HOME/Repositories/atno11/dotfiles"

backup_path() {
    local target="$1"

    [[ -e "$target" || -L "$target" ]] || return 0

    local backup_root
    backup_root="$HOME/.local/state/arch-setup/backups"

    mkdir -p "$backup_root"

    local relative
    relative="${target#"$HOME"/}"

    local destination
    destination="$backup_root/$relative"

    mkdir -p "$(dirname "$destination")"

    if [[ -e "$destination" || -L "$destination" ]]; then
        destination="${destination}.$(date +%Y%m%d-%H%M%S)"
    fi

    echo "    backup: $target -> $destination"
    mv "$target" "$destination"
}

link_path() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" && ! -L "$source" ]]; then
        echo "    source missing: $source"
        return 1
    fi

    mkdir -p "$(dirname "$target")"

    if [[ -L "$target" ]]; then
        local current_target
        local expected_target

        current_target="$(
            readlink -f "$target" 2>/dev/null || true
        )"

        expected_target="$(
            readlink -f "$source" 2>/dev/null || true
        )"

        if [[ -n "$current_target" &&
              "$current_target" == "$expected_target" ]]; then
            echo "    already linked: $target"
            return 0
        fi
    fi

    backup_path "$target"

    ln -s "$source" "$target"

    echo "    linked: $target -> $source"
}

prepare_dotfiles_repository() {
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        echo "==> Dotfiles repository already present."
        return
    fi

    if [[ -e "$DOTFILES_DIR" ]]; then
        echo "ERROR: $DOTFILES_DIR exists but is not a Git repository." >&2
        return 1
    fi

    echo "==> Cloning dotfiles..."

    mkdir -p "$(dirname "$DOTFILES_DIR")"

    git clone \
        "$DOTFILES_REPO_URL" \
        "$DOTFILES_DIR"
}

link_config_directories() {
    echo
    echo "==> Linking ~/.config..."

    mkdir -p "$HOME/.config"

    local source

    while IFS= read -r -d '' source; do
        local name
        name="$(basename "$source")"

        # PipeWire contains machine-specific generated configuration
        # and is handled separately.
        if [[ "$name" == "pipewire" ]]; then
            continue
        fi

        link_path \
            "$source" \
            "$HOME/.config/$name"
    done < <(
        find "$DOTFILES_DIR/.config" \
            -mindepth 1 \
            -maxdepth 1 \
            -print0 |
            sort -z
    )
}

link_pipewire_config() {
    echo
    echo "==> Linking PipeWire configuration..."

    local source_dir
    local target_dir

    source_dir="$DOTFILES_DIR/.config/pipewire/pipewire.conf.d"
    target_dir="$HOME/.config/pipewire/pipewire.conf.d"

    if [[ ! -d "$source_dir" ]]; then
        echo "ERROR: PipeWire dotfiles directory not found: $source_dir" >&2
        return 1
    fi

    mkdir -p "$target_dir"

    local source

    while IFS= read -r -d '' source; do
        local name
        name="$(basename "$source")"

        link_path \
            "$source" \
            "$target_dir/$name"
    done < <(
        find "$source_dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type f \
            -name '*.conf' \
            -print0 |
            sort -z
    )
}

link_local_bin() {
    echo
    echo "==> Linking ~/.local/bin..."

    link_path \
        "$DOTFILES_DIR/.local/bin" \
        "$HOME/.local/bin"
}

link_local_share_entries() {
    local source_root="$DOTFILES_DIR/.local/share"

    [[ -d "$source_root" ]] || return 0

    echo
    echo "==> Linking ~/.local/share entries..."

    mkdir -p "$HOME/.local/share"

    local source

    while IFS= read -r -d '' source; do
        local name
        name="$(basename "$source")"

        link_path \
            "$source" \
            "$HOME/.local/share/$name"
    done < <(
        find "$source_root" \
            -mindepth 1 \
            -maxdepth 1 \
            -print0 |
            sort -z
    )
}

link_home_files() {
    echo
    echo "==> Linking home files..."

    local files=(
        .profile
        .zshenv
        .Xresources
        .XCompose
    )

    local name

    for name in "${files[@]}"; do
        [[ -e "$DOTFILES_DIR/$name" ]] || continue

        link_path \
            "$DOTFILES_DIR/$name" \
            "$HOME/$name"
    done
}

link_home_directories() {
    echo
    echo "==> Linking home directories..."

    local directories=(
        .xkb
    )

    local name

    for name in "${directories[@]}"; do
        [[ -d "$DOTFILES_DIR/$name" ]] || continue

        link_path \
            "$DOTFILES_DIR/$name" \
            "$HOME/$name"
    done
}

link_icon_defaults() {
    local source
    local target

    source="$DOTFILES_DIR/.icons/default"
    target="$HOME/.icons/default"

    [[ -d "$source" ]] || return 0

    echo
    echo "==> Linking default icon theme..."

    mkdir -p "$HOME/.icons"

    link_path \
        "$source" \
        "$target"
}

prepare_runtime_directories() {
    echo
    echo "==> Preparing runtime directories..."

    mkdir -p \
        "$HOME/.cache" \
        "$HOME/.local/state" \
        "$HOME/.local/share"
}

validate_dotfiles() {
    echo
    echo "==> Validating dotfiles..."

    local required=(
        "$HOME/.config/bspwm"
        "$HOME/.config/polybar"
        "$HOME/.config/picom"
        "$HOME/.config/zsh"
        "$HOME/.config/ghostty"
        "$HOME/.config/pipewire/pipewire.conf.d/10-virtual.conf"
        "$HOME/.config/pipewire/pipewire.conf.d/20-recv.conf"
        "$HOME/.config/pipewire/pipewire.conf.d/40-mic.conf"
        "$HOME/.icons/default"
        "$HOME/.local/bin"
        "$HOME/.zshenv"
    )

    local path
    local failed=0

    for path in "${required[@]}"; do
        if [[ -e "$path" || -L "$path" ]]; then
            echo "    OK   $path"
        else
            echo "    MISS $path"
            failed=1
        fi
    done

    ((failed == 0))
}

install_dotfiles() {
    echo
    echo "==> Installing dotfiles..."

    prepare_dotfiles_repository
    prepare_runtime_directories

    link_config_directories
    link_pipewire_config
    link_local_bin
    link_local_share_entries
    link_home_files
    link_home_directories
    link_icon_defaults

    validate_dotfiles
}

#!/usr/bin/env bash

AUR_PACKAGES=(
    oh-my-posh
    xkb-switch
    i3lock-color
    pawlette-git
)

install_yay() {
    if command -v yay >/dev/null 2>&1; then
        echo "==> yay already installed."
        return
    fi

    echo
    echo "==> Installing yay..."

    local tmp_dir

    tmp_dir="$(mktemp -d)"

    git clone \
        https://aur.archlinux.org/yay.git \
        "$tmp_dir/yay"

    (
        cd "$tmp_dir/yay"
        makepkg -si --noconfirm
    )

    rm -rf "$tmp_dir"
}

install_aur_packages() {
    echo
    echo "==> Installing AUR packages..."

    yay -S --needed --noconfirm \
        "${AUR_PACKAGES[@]}"
}

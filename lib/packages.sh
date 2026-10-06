#!/usr/bin/env bash

PACMAN_PACKAGES=(
    # Base development
    base-devel
    git
    sudo
    pciutils

    # Desktop / X11
    xorg-server
    xorg-xrandr
    xorg-xdpyinfo
    xorg-xsetroot
    xorg-xset
    xorg-setxkbmap
    xorg-xrdb

    bspwm
    sxhkd
    sddm

    # Terminal / shell / editors
    ghostty
    zsh
    neovim
    nano

    # Fonts
    ttf-jetbrains-mono-nerd

    # Launcher / file manager
    rofi
    rofimoji
    nemo

    # Desktop components
    polybar
    picom
    dunst
    xsettingsd

    # CLI tools
    lsd
    bat
    fzf
    zoxide
    yazi
    ripgrep
    fd
    jq
    btop
    wget
    pyenv

    # Screenshots / media
    flameshot
    playerctl

    # X11 utilities
    xclip
    cliphist
    clipnotify
    xcolor
    feh

    # Audio controls
    pamixer
    pavucontrol

    # Brightness
    brightnessctl

    # Notifications
    libnotify

    # Image / archive / misc
    imagemagick
    curl
    tar
    unzip
    pacman-contrib

    # Networking
    networkmanager

    # Bluetooth
    bluez
    bluez-utils
    blueman

    # PipeWire
    pipewire
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    wireplumber

    # Polkit
    polkit
    polkit-gnome

    # Python
    python
    python-psutil
    python-pipx
)

install_official_packages() {
    echo
    echo "==> Installing official packages..."

    sudo pacman -Syu \
        --needed \
        --noconfirm \
        "${PACMAN_PACKAGES[@]}"
}

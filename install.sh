#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
        pwd
)"

source "$ROOT_DIR/lib/packages.sh"
source "$ROOT_DIR/lib/hardware.sh"
source "$ROOT_DIR/lib/aur.sh"
source "$ROOT_DIR/lib/dotfiles.sh"
source "$ROOT_DIR/lib/theme.sh"
source "$ROOT_DIR/lib/audio.sh"
source "$ROOT_DIR/lib/services.sh"

main() {
    echo
    echo "========================================"
    echo " Arch Setup"
    echo "========================================"
    echo

    install_official_packages
    install_hardware_packages
    install_yay
    install_aur_packages
    install_dotfiles
    install_theme
    configure_audio
    enable_services

    echo
    echo "========================================"
    echo " Installation complete"
    echo "========================================"
}

main "$@"

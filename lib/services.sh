#!/usr/bin/env bash

enable_services() {
    echo
    echo "==> Enabling system services..."

    sudo systemctl enable NetworkManager.service
    sudo systemctl enable bluetooth.service
    sudo systemctl enable sddm.service
}

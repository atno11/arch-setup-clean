#!/usr/bin/env bash

install_cpu_microcode() {
    local vendor

    vendor="$(
        lscpu |
            awk -F: '/Vendor ID/ {
                gsub(/^[ \t]+|[ \t]+$/, "", $2)
                print $2
                exit
            }'
    )"

    case "$vendor" in
        GenuineIntel)
            echo "==> Intel CPU detected."
            sudo pacman -S --needed --noconfirm intel-ucode
            ;;

        AuthenticAMD)
            echo "==> AMD CPU detected."
            sudo pacman -S --needed --noconfirm amd-ucode
            ;;

        *)
            echo "==> Unknown CPU vendor: ${vendor:-unknown}"
            ;;
    esac
}

install_gpu_packages() {
    local gpu_info

    gpu_info="$(
        lspci -nn |
            grep -Ei 'VGA compatible controller|3D controller|Display controller' ||
            true
    )"

    if grep -Eqi 'AMD/ATI|Advanced Micro Devices' <<<"$gpu_info"; then
        echo "==> AMD GPU detected."

        sudo pacman -S --needed --noconfirm \
            mesa \
            vulkan-radeon \
            xf86-video-amdgpu
    fi

    if grep -Eqi '\bIntel\b' <<<"$gpu_info"; then
        echo "==> Intel GPU detected."

        sudo pacman -S --needed --noconfirm \
            mesa \
            vulkan-intel
    fi

    if grep -Eqi '\bNVIDIA\b' <<<"$gpu_info"; then
        echo "==> NVIDIA GPU detected."

        sudo pacman -S --needed --noconfirm \
            nvidia \
            nvidia-utils
    fi
}

install_hardware_packages() {
    echo
    echo "==> Detecting hardware..."

    install_cpu_microcode
    install_gpu_packages
}

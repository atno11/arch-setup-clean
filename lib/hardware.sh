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

            sudo pacman -S \
                --needed \
                --noconfirm \
                intel-ucode
            ;;

        AuthenticAMD)
            echo "==> AMD CPU detected."

            sudo pacman -S \
                --needed \
                --noconfirm \
                amd-ucode
            ;;

        *)
            echo "==> Unknown CPU vendor: ${vendor:-unknown}"
            ;;
    esac
}

get_installed_kernel_packages() {
    pacman -Qq |
        grep -E '^(linux|linux-lts|linux-zen|linux-hardened)$' ||
        true
}

install_nvidia_packages() {
    local kernels=()
    local kernel
    local packages=(
        nvidia-utils
    )

    mapfile -t kernels < <(get_installed_kernel_packages)

    if ((${#kernels[@]} == 0)); then
        echo "ERROR: No supported Arch kernel package detected." >&2
        return 1
    fi

    for kernel in "${kernels[@]}"; do
        case "$kernel" in
            linux)
                packages+=(
                    nvidia-open
                )
                ;;

            linux-lts)
                packages+=(
                    nvidia-open-lts
                )
                ;;

            linux-zen | linux-hardened)
                packages+=(
                    nvidia-open-dkms
                    "${kernel}-headers"
                )
                ;;

            *)
                echo "ERROR: Unsupported kernel for NVIDIA: $kernel" >&2
                return 1
                ;;
        esac
    done

    echo "==> NVIDIA packages:"
    printf '    %s\n' "${packages[@]}"

    sudo pacman -S \
        --needed \
        --noconfirm \
        "${packages[@]}"
}

install_gpu_packages() {
    local gpu_info

    gpu_info="$(
        lspci -nn |
            grep -Ei \
                'VGA compatible controller|3D controller|Display controller' ||
            true
    )"

    if grep -Eqi \
        'AMD/ATI|Advanced Micro Devices' \
        <<<"$gpu_info"; then

        echo "==> AMD GPU detected."

        sudo pacman -S \
            --needed \
            --noconfirm \
            mesa \
            vulkan-radeon \
            xf86-video-amdgpu
    fi

    if grep -Eqi '\bIntel\b' <<<"$gpu_info"; then
        echo "==> Intel GPU detected."

        sudo pacman -S \
            --needed \
            --noconfirm \
            mesa \
            vulkan-intel
    fi

    if grep -Eqi '\bNVIDIA\b' <<<"$gpu_info"; then
        echo "==> NVIDIA GPU detected."

        install_nvidia_packages
    fi
}

install_hardware_packages() {
    echo
    echo "==> Detecting hardware..."

    install_cpu_microcode
    install_gpu_packages
}

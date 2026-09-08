#!/usr/bin/env bash
set -euo pipefail

# Build helper script for Collabora Office on Arch Linux
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"

cd "${ROOT_DIR}"

echo "================================================================="
echo " Starting Collabora Office native package build (makepkg)"
echo "================================================================="

# Check CPU and available RAM
CORES=$(nproc)
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))

echo "Detected CPU Cores: ${CORES}"
echo "Detected RAM: ${TOTAL_RAM_GB} GB"

if [ "${TOTAL_RAM_GB}" -lt 8 ]; then
    echo "WARNING: Building Collabora Office requires at least 8-16 GB of RAM/Swap."
    echo "Consider adding swap space to prevent Out-Of-Memory during linking."
fi

# Enable ccache if installed
if command -v ccache >/dev/null 2>&1; then
    echo "ccache detected: Build acceleration enabled."
    export CCACHE_DIR="${HOME}/.ccache"
fi

# Run makepkg
# -s: install missing build dependencies automatically via pacman
# -i: install package upon successful build
# -r: remove build-time dependencies afterward (optional)
makepkg -s "$@"

echo "================================================================="
echo " Build completed successfully."
echo "================================================================="

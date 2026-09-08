#!/usr/bin/env bash
set -euo pipefail

# Clean helper script for Collabora Office packaging workspace
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"

cd "${ROOT_DIR}"

echo "Cleaning build staging directories..."
rm -rf src/ pkg/ fakeinstall/ *.log

echo "Do you also want to remove downloaded git/source repositories? (y/N)"
read -r answer || answer="n"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf core/ *.pkg.tar.zst
    echo "Removed source repositories and built packages."
fi

echo "Workspace clean."

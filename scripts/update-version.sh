#!/usr/bin/env bash
set -euo pipefail

# Script to query latest Collabora Enterprise branch commit/version
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"

cd "${ROOT_DIR}"

BRANCH="distro/collabora/co-24.04"
REPO="https://github.com/LibreOffice/core.git"

echo "Querying remote Git repository for branch ${BRANCH}..."
LATEST_COMMIT=$(git ls-remote "${REPO}" "refs/heads/${BRANCH}" | awk '{print $1}')

echo "Latest commit on ${BRANCH}: ${LATEST_COMMIT}"

# Fetch configure.ac from GitHub to inspect version
TEMP_CONF=$(mktemp)
curl -sL "https://raw.githubusercontent.com/LibreOffice/core/${BRANCH}/configure.ac" -o "${TEMP_CONF}"

DETECTED_VER=$(grep -E "^AC_INIT\(\[Collabora Office\]" "${TEMP_CONF}" | sed -E 's/.*\[([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\].*/\1/')
rm -f "${TEMP_CONF}"

echo "Detected upstream version: ${DETECTED_VER}"

CURRENT_VER=$(grep -E "^pkgver=" PKGBUILD | cut -d= -f2)
echo "Current PKGBUILD version: ${CURRENT_VER}"

if [ "${DETECTED_VER}" != "${CURRENT_VER}" ]; then
    echo "New version available! Updating PKGBUILD..."
    sed -i "s/^pkgver=.*/pkgver=${DETECTED_VER}/" PKGBUILD
    sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD
    echo "Regenerating .SRCINFO..."
    if command -v makepkg >/dev/null 2>&1; then
        makepkg --printsrcinfo > .SRCINFO
    fi
    echo "Updated to version ${DETECTED_VER}."
else
    echo "PKGBUILD is already up-to-date with upstream ${BRANCH}."
fi

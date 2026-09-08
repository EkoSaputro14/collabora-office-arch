#!/usr/bin/env bash
set -euo pipefail

# Validation script for built Collabora Office Arch Linux package
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"

echo "================================================================="
echo " Validating Collabora Office Package Artifact"
echo "================================================================="

# Locate built .pkg.tar.zst package
PKG_FILE=$(find "${ROOT_DIR}" -maxdepth 2 -name "collabora-office-*.pkg.tar.zst" | head -n 1)

if [ -z "${PKG_FILE}" ]; then
    echo "ERROR: No built package found in ${ROOT_DIR}. Run 'makepkg' first."
    exit 1
fi

echo "Found package: ${PKG_FILE}"

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

echo "Inspecting package table of contents..."
tar -tf "${PKG_FILE}" > "${TEMP_DIR}/filelist.txt"

# 1. Verify binary location
echo "[CHECK 1] Verifying installation path (/usr/lib/collaboraoffice)..."
if grep -q "^usr/lib/collaboraoffice/program/soffice.bin" "${TEMP_DIR}/filelist.txt"; then
    echo "  PASS: /usr/lib/collaboraoffice/program/soffice.bin exists."
else
    echo "  FAIL: Missing /usr/lib/collaboraoffice/program/soffice.bin"
    exit 1
fi

# 2. Verify wrapper binaries in /usr/bin
echo "[CHECK 2] Verifying wrapper executables in /usr/bin..."
for bin in collaboraoffice collaboraoffice-writer collaboraoffice-calc collaboraoffice-impress collaboraoffice-draw collaboraoffice-base collaboraoffice-math; do
    if grep -q "^usr/bin/${bin}" "${TEMP_DIR}/filelist.txt"; then
        echo "  PASS: usr/bin/${bin} is present."
    else
        echo "  FAIL: usr/bin/${bin} is missing!"
        exit 1
    fi
done

# 3. Verify desktop integration
echo "[CHECK 3] Verifying desktop files in /usr/share/applications..."
for app in writer calc impress draw base math; do
    if grep -q "usr/share/applications/collaboraoffice-${app}.desktop" "${TEMP_DIR}/filelist.txt"; then
        echo "  PASS: collaboraoffice-${app}.desktop present."
    else
        echo "  FAIL: collaboraoffice-${app}.desktop missing!"
        exit 1
    fi
done

# 4. Verify MIME definition
echo "[CHECK 4] Verifying MIME database definitions..."
if grep -q "usr/share/mime/packages/collaboraoffice.xml" "${TEMP_DIR}/filelist.txt"; then
    echo "  PASS: collaboraoffice.xml is included."
else
    echo "  FAIL: collaboraoffice.xml missing from package!"
    exit 1
fi

# 5. Verify Brand Icons
echo "[CHECK 5] Verifying official icons..."
if grep -q "usr/share/icons/hicolor/scalable/apps/collaboraoffice-writer.svg" "${TEMP_DIR}/filelist.txt" || \
   grep -q "usr/share/icons/hicolor/128x128/apps/collaboraoffice-writer.png" "${TEMP_DIR}/filelist.txt"; then
    echo "  PASS: High-resolution brand icons present."
else
    echo "  FAIL: Brand icons missing!"
    exit 1
fi

# 6. Verify Python UNO bindings
echo "[CHECK 6] Verifying Python UNO module integration..."
if grep -E -q "usr/lib/python.*/site-packages/uno.py" "${TEMP_DIR}/filelist.txt"; then
    echo "  PASS: Python uno.py is present in site-packages."
else
    echo "  FAIL: Python uno.py missing from site-packages!"
    exit 1
fi

echo "================================================================="
echo " ALL STRUCTURAL PACKAGE CHECKS PASSED!"
echo "================================================================="

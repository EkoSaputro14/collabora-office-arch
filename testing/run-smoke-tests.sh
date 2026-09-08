#!/usr/bin/env bash
set -euo pipefail

# Smoke tests to run against an installed collabora-office package
echo "================================================================="
echo " Collabora Office Smoke & Runtime Conversion Tests"
echo "================================================================="

if ! command -v collaboraoffice >/dev/null 2>&1; then
    echo "ERROR: 'collaboraoffice' is not installed or not in PATH."
    echo "Install package first: sudo pacman -U collabora-office-*.pkg.tar.zst"
    exit 1
fi

TMP_TEST_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_TEST_DIR}"' EXIT

cd "${TMP_TEST_DIR}"

echo "[TEST 1] Testing Collabora Office CLI reporting..."
collaboraoffice --version

echo "[TEST 2] Testing Headless Document Conversion (.odt -> .pdf)..."
cat << 'EOF' > test-doc.odt.html
<!DOCTYPE html>
<html>
<body>
<h1>Collabora Office Arch Linux Native Test</h1>
<p>Testing headless rendering engine and font rasterization.</p>
</body>
</html>
EOF

collaboraoffice --headless --convert-to pdf test-doc.odt.html --outdir .
if [ -f "test-doc.odt.pdf" ] && [ -s "test-doc.odt.pdf" ]; then
    echo "  PASS: test-doc.odt.pdf created successfully ($(stat -c%s test-doc.odt.pdf) bytes)."
else
    echo "  FAIL: Document conversion failed."
    exit 1
fi

echo "[TEST 3] Testing Python UNO bridge import..."
python -c '
import uno
print("  PASS: Successfully imported Python uno module!")
'

echo "================================================================="
echo " ALL SMOKE TESTS COMPLETED SUCCESSFULLY!"
echo "================================================================="

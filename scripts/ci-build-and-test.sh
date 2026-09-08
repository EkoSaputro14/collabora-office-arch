#!/usr/bin/env bash
set -euo pipefail

# CI Build and Validation Script for Arch Linux Container
WORKSPACE="/workspace"
ARTIFACTS_DIR="${WORKSPACE}/artifacts"

mkdir -p "${ARTIFACTS_DIR}"

echo "================================================================="
echo " [STEP 1] Initializing Clean Arch Linux Environment"
echo "================================================================="
pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm

echo "================================================================="
echo " [STEP 2] Installing Core Build Tools"
echo "================================================================="
# Only install core packaging tools; all other dependencies are resolved
# automatically by makepkg -s to test unattended dependency resolution
pacman -S --needed --noconfirm base-devel git ccache sudo namcap wget curl

# Optimize makepkg for CI environment
echo 'GITFLAGS="--depth=1"' >> /etc/makepkg.conf
echo 'BUILDENV=(!distcc color !leflags ccache !check !sign)' >> /etc/makepkg.conf
echo 'MAKEFLAGS="-j$(nproc)"' >> /etc/makepkg.conf

echo "================================================================="
echo " [STEP 3] Setting up Unprivileged Build User (builder)"
echo "================================================================="
if ! id builder >/dev/null 2>&1; then
  useradd -m -G wheel builder
  echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi
chown -R builder:builder "${WORKSPACE}"

echo "================================================================="
echo " [STEP 4] Running Namcap on PKGBUILD"
echo "================================================================="
su - builder -c "
  cd ${WORKSPACE}
  echo 'Running namcap on PKGBUILD...'
  namcap PKGBUILD 2>&1 | tee ${ARTIFACTS_DIR}/namcap-pkgbuild.log || true
"

echo "================================================================="
echo " [STEP 5] Building Native Package via makepkg -s"
echo "================================================================="
# makepkg -s will automatically install all depends and makedepends via pacman
su - builder -c "
  cd ${WORKSPACE}
  makepkg -s --noconfirm 2>&1 | tee ${ARTIFACTS_DIR}/makepkg-build.log
"

PKG_FILE=$(find "${WORKSPACE}" -maxdepth 1 -name "collabora-office-*.pkg.tar.zst" | head -n 1)
if [ -z "${PKG_FILE}" ]; then
  echo "ERROR: makepkg failed to produce .pkg.tar.zst file!"
  exit 1
fi
echo "==> Successfully built package: ${PKG_FILE}"
cp "${PKG_FILE}" "${ARTIFACTS_DIR}/"

echo "================================================================="
echo " [STEP 6] Running Namcap on Built Package"
echo "================================================================="
namcap "${PKG_FILE}" 2>&1 | tee "${ARTIFACTS_DIR}/namcap-package.log" || true

echo "================================================================="
echo " [STEP 7] Installing Package in Clean Environment"
echo "================================================================="
pacman -U --noconfirm "${PKG_FILE}" 2>&1 | tee "${ARTIFACTS_DIR}/pacman-install.log"

echo "================================================================="
echo " [STEP 8] Querying Package Information & Files"
echo "================================================================="
pacman -Qip "${PKG_FILE}" | tee "${ARTIFACTS_DIR}/pacman-qip.log"
pacman -Qlp "${PKG_FILE}" | tee "${ARTIFACTS_DIR}/pacman-qlp.log"

echo "================================================================="
echo " [STEP 9] Checking Shared Library Linkage (ldd)"
echo "================================================================="
ldd /usr/lib/collaboraoffice/program/soffice.bin | tee "${ARTIFACTS_DIR}/ldd-soffice.log"
if grep -q "not found" "${ARTIFACTS_DIR}/ldd-soffice.log"; then
  echo "ERROR: Unresolved shared libraries detected in soffice.bin!"
  exit 1
fi
echo "PASS: All shared libraries resolved cleanly."

echo "================================================================="
echo " [STEP 10] Running Smoke Tests"
echo "================================================================="
{
  echo "=== Test 1: CLI Version Check ==="
  collaboraoffice --version

  echo "=== Test 2: Python UNO Import ==="
  python -c 'import uno; print("Python UNO imported successfully:", uno)'

  echo "=== Test 3: Headless Conversion Test ==="
  cat << 'EOF' > /tmp/sample.html
<!DOCTYPE html>
<html>
<body>
<h1>Collabora Office Arch Native Test</h1>
<p>Verifying headless rendering engine and font rasterization in clean container.</p>
</body>
</html>
EOF
  collaboraoffice --headless --convert-to pdf /tmp/sample.html --outdir /tmp
  if [ -s /tmp/sample.pdf ]; then
    echo "PASS: Document converted to PDF successfully ($(stat -c%s /tmp/sample.pdf) bytes)."
  else
    echo "FAIL: Headless conversion failed."
    exit 1
  fi
} 2>&1 | tee "${ARTIFACTS_DIR}/smoke-test.log"

echo "================================================================="
echo " ALL TARGET VERIFICATIONS COMPLETED SUCCESSFULLY!"
echo "================================================================="

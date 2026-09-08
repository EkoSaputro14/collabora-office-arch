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
echo " [STEP 2] Installing Build Toolchain & Dependencies"
echo "================================================================="
pacman -S --needed --noconfirm \
  git ccache sudo namcap curl hunspell python libwpd libwps neon pango \
  nspr libjpeg-turbo libxrandr libgl redland hyphen lpsolve graphite icu \
  libxslt lcms2 poppler libvisio libetonyek libodfgen libcdr libmspub \
  harfbuzz-icu nss clucene hicolor-icon-theme libpagemaker libxinerama \
  libabw libmwaw libe-book libcups liblangtag libexttextcat liborcus \
  libwebp libcmis libtommath libzmf libatomic_ops xmlsec libnumbertext \
  gpgmepp libfreehand libstaroffice libepubgen libqxp libepoxy zxing-cpp \
  xdg-utils fontconfig zlib libpng freetype2 cairo libx11 expat glib2 \
  boost-libs libtiff dbus glibc librevenge libxext openjpeg2 argon2 md4c \
  gcc clang perl-archive-zip zip unzip gperf gtk3 qt6-base boost mdds \
  glm fast_float dragonbox box2d cppunit beanshell ant java-environment=17 \
  coin-or-mp doxygen

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
  namcap PKGBUILD 2>&1 | tee ${ARTIFACTS_DIR}/namcap-pkgbuild.log || true
"

echo "================================================================="
echo " [STEP 5] Building Native Package via makepkg"
echo "================================================================="
su - builder -c "
  cd ${WORKSPACE}
  export MAKEFLAGS=\"-j\$(nproc)\"
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

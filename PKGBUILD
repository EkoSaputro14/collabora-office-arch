# Maintainer: Eko Saputro <ekolepi>
# Contributor: Collabora Productivity Ltd. Packaging Team
# Reference: Arch Linux libreoffice-fresh packaging

pkgname=collabora-office
pkgver=24.04.17.3
pkgrel=1
pkgdesc="Collabora Office Desktop - Enterprise-grade office suite built natively from source"
arch=('x86_64')
url="https://www.collaboraoffice.com/"
license=('MPL-2.0' 'LGPL-3.0-or-later')
install="${pkgname}.install"

# Arch Linux System Dependencies (Shared Libraries)
depends=(
    'curl>=7.20.0' 'hunspell>=1.2.8' 'python' 'libwpd>=0.9.2' 'libwps' 'libwpg'
    'neon>=0.28.6' 'pango' 'nspr' 'libjpeg-turbo' 'libxrandr' 'libgl'
    'redland' 'hyphen' 'lpsolve' 'gcc-libs' 'libgcc' 'sh' 'graphite' 'icu' 'libxslt'
    'lcms2' 'poppler' 'libvisio' 'libetonyek' 'libodfgen' 'libcdr'
    'libmspub' 'harfbuzz-icu' 'nss' 'clucene' 'hicolor-icon-theme' 'libpagemaker'
    'libxinerama' 'libabw' 'libmwaw' 'libe-book' 'libcups'
    'liblangtag' 'libexttextcat' 'libwebp' 'libcmis'
    'libtommath' 'libzmf' 'libatomic_ops' 'xmlsec' 'libnumbertext' 'gpgmepp'
    'libfreehand' 'libstaroffice' 'libepubgen' 'libqxp' 'libepoxy'
    'zxing-cpp' 'xdg-utils' 'fontconfig' 'zlib' 'libpng' 'freetype2'
    'cairo' 'libx11' 'expat' 'glib2' 'boost-libs' 'libtiff' 'dbus' 'glibc'
    'librevenge' 'libxext' 'openjpeg2' 'argon2' 'md4c' 'libxml2' 'libmythes'
    'bluez-libs' 'python-lxml' 'libldap'
)

# Build Tools & Development Headers
makedepends=(
    'git' 'gcc' 'clang' 'ccache' 'perl-archive-zip' 'zip' 'unzip'
    'gperf' 'gtk3' 'qt6-base' 'boost' 'glm' 'box2d'
    'cppunit' 'beanshell' 'ant' 'java-environment=17'
    'coin-or-mp' 'coin-or-coinutils' 'doxygen' 'wget' 'abseil-cpp' 'gobject-introspection'
    'python-setuptools' 'libffi' 'sane' 'unixodbc' 'gst-plugins-base-libs'
    'mariadb-libs' 'postgresql-libs' 'rhino'
)

optdepends=(
    'gtk3: Native GTK3 desktop interface (GNOME/XFCE)'
    'qt6-base: Native Qt6 desktop interface (KDE Plasma)'
    'ttf-liberation: Standard Liberation font family'
    'ttf-dejavu: Standard DejaVu font family'
    'ttf-carlito: Carlito font family (Calibri alternative)'
    'hunspell-id: Indonesian spellchecker dictionary'
    'hyphen-id: Indonesian hyphenation rules'
)

# Allows side-by-side coexistence or clean alternative to stock LibreOffice
provides=('libreoffice' 'collabora-office')
conflicts=('libreoffice-fresh' 'libreoffice-still')
options=('!lto' 'ccache')

# Collabora enterprise branch
_gitrepo="https://github.com/LibreOffice/core.git"
_gitbranch="distro/collabora/co-24.04"

source=(
    "core::git+${_gitrepo}#branch=${_gitbranch}"
    "collaboraoffice.sh"
    "collaboraoffice.csh"
    "soffice-template.desktop.in"
)
sha256sums=(
    'SKIP'
    '28483e1bba275917af0bd70777fc58228be1a99b62d443b884543e165ac63bf2'
    '95351055f45d9fbadc262133b162730c4944a08ada66f2fae62139f731ac4912'
    '1c2a65704deb69c0a1ebf142776cc7edcddfea36867fbbd086c35e2a62aaf921'
)

prepare() {
    cd "${srcdir}/core"

    # Memory allocation compatibility: LibreOffice internal allocator
    # uses malloc_usable_size, which requires fortification level 2
    export CFLAGS="${CFLAGS/_FORTIFY_SOURCE=3/_FORTIFY_SOURCE=2}"
    export CXXFLAGS="${CXXFLAGS/_FORTIFY_SOURCE=3/_FORTIFY_SOURCE=2}"

    # Build minimal debug symbols to optimize compile time and package size (~220MB vs ~1.8GB)
    export CFLAGS="${CFLAGS/-g /-g1 }"
    export CXXFLAGS="${CXXFLAGS/-g /-g1 }"

    # Pre-fetch required internal tarballs according to download.lst
    if [ ! -f "src.downloaded" ]; then
        echo "==> Fetching external dependencies defined in download.lst..."
        make fetch || true
        touch src.downloaded
    fi
}

build() {
    cd "${srcdir}/core"

    _PARALLEL=$(nproc)

    echo "==> Configuring Collabora Office Desktop build with ${_PARALLEL} jobs..."

    ./autogen.sh \
        --prefix=/usr \
        --exec-prefix=/usr \
        --sysconfdir=/etc \
        --libdir=/usr/lib \
        --mandir=/usr/share/man \
        --with-vendor="Collabora Productivity Ltd." \
        --with-branding=icon-themes/galaxy/brand_cp \
        --with-extra-buildid="${pkgver}-${pkgrel}-Arch" \
        --with-parallelism="${_PARALLEL}" \
        --enable-release-build \
        --enable-mergelibs \
        --enable-lto \
        --enable-ccache \
        --without-junit \
        --with-help=html \
        --disable-dconf \
        --disable-online-update \
        --enable-dbus \
        --enable-gio \
        --enable-gtk3 \
        --enable-qt6 \
        --disable-gtk4 \
        --enable-split-app-modules \
        --with-theme="colibre colibre_dark breeze breeze_dark elementary" \
        --with-system-libs \
        --with-system-headers \
        --with-system-boost \
        --with-system-icu \
        --with-system-cairo \
        --with-system-clucene \
        --with-system-cppunit \
        --with-system-graphite \
        --with-system-glm \
        --with-system-libnumbertext \
        --with-system-libwpg \
        --with-system-libwps \
        --with-system-redland \
        --with-system-libzmf \
        --with-system-gpgmepp \
        --with-system-libstaroffice \
        --with-system-libxml \
        --with-system-libcdr \
        --without-system-mdds \
        --with-system-libvisio \
        --with-system-libcmis \
        --with-system-libmspub \
        --with-system-libexttextcat \
        --without-system-orcus \
        --with-system-liblangtag \
        --with-system-libodfgen \
        --with-system-libmwaw \
        --with-system-libetonyek \
        --with-system-libfreehand \
        --with-system-zxing \
        --with-system-libtommath \
        --with-system-libatomic-ops \
        --with-system-libebook \
        --with-system-libabw \
        --with-system-coinmp \
        --with-system-dicts \
        --with-external-dict-dir=/usr/share/hunspell \
        --with-external-hyph-dir=/usr/share/hyphen \
        --with-external-thes-dir=/usr/share/mythes \
        --with-jdk-home="/usr/lib/jvm/default" \
        --with-ant-home="/usr/share/ant" \
        --enable-openssl \
        --disable-dependency-tracking \
        --without-system-firebird \
        --without-system-hsqldb \
        --without-system-box2d \
        --without-system-dragonbox \
        --without-system-libfixmath \
        --without-system-frozen \
        --without-system-zxcvbn \
        --without-system-jars \
        --disable-report-builder \
        --without-fonts

    echo "==> Compiling Collabora Office..."
    make build

    echo "==> Staging install via distro-pack-install..."
    mkdir -p "${srcdir}/fakeinstall"
    make DESTDIR="${srcdir}/fakeinstall" distro-pack-install
}

package() {
    # 1. Transfer staged files to packaging root
    cp -a "${srcdir}/fakeinstall/"* "${pkgdir}/"

    # 2. Configuration files in /etc/collaboraoffice
    install -dm755 "${pkgdir}/etc/collaboraoffice"
    if [ -f "${pkgdir}/usr/lib/collaboraoffice/program/bootstraprc" ]; then
        mv "${pkgdir}/usr/lib/collaboraoffice/program/bootstraprc" "${pkgdir}/etc/collaboraoffice/"
        ln -sf /etc/collaboraoffice/bootstraprc "${pkgdir}/usr/lib/collaboraoffice/program/bootstraprc"
    fi
    if [ -f "${pkgdir}/usr/lib/collaboraoffice/program/sofficerc" ]; then
        mv "${pkgdir}/usr/lib/collaboraoffice/program/sofficerc" "${pkgdir}/etc/collaboraoffice/"
        ln -sf /etc/collaboraoffice/sofficerc "${pkgdir}/usr/lib/collaboraoffice/program/sofficerc"
    fi

    # 3. Environment preset profile scripts
    install -dm755 "${pkgdir}/etc/profile.d"
    install -m644 "${srcdir}/collaboraoffice.sh" "${pkgdir}/etc/profile.d/collaboraoffice.sh"
    install -m644 "${srcdir}/collaboraoffice.csh" "${pkgdir}/etc/profile.d/collaboraoffice.csh"

    # 4. Binary executables in /usr/bin
    install -dm755 "${pkgdir}/usr/bin"
    ln -sf /usr/lib/collaboraoffice/program/soffice "${pkgdir}/usr/bin/collaboraoffice"

    # Application wrappers
    for app in writer calc impress draw base math; do
        cat <<EOF > "${pkgdir}/usr/bin/collaboraoffice-${app}"
#!/bin/sh
exec /usr/lib/collaboraoffice/program/soffice --${app} "\$@"
EOF
        chmod 755 "${pkgdir}/usr/bin/collaboraoffice-${app}"
    done

    # 5. Upstream Python UNO Integration
    local site_packages=$(python -c "import site; print(site.getsitepackages()[0])")
    install -dm755 "${pkgdir}/${site_packages}"
    cat <<EOF > "${pkgdir}/${site_packages}/uno.py"
import sys, os
sys.path.append('/usr/lib/collaboraoffice/program/')
os.putenv('URE_BOOTSTRAP', 'vnd.sun.star.pathname:/usr/lib/collaboraoffice/program/fundamentalrc')
EOF
    if [ -f "${pkgdir}/usr/lib/collaboraoffice/program/uno.py" ]; then
        cat "${pkgdir}/usr/lib/collaboraoffice/program/uno.py" >> "${pkgdir}/${site_packages}/uno.py"
        rm -f "${pkgdir}/usr/lib/collaboraoffice/program/uno.py"
    fi
    for pyhelper in unohelper.py officehelper.py; do
        if [ -f "${pkgdir}/usr/lib/collaboraoffice/program/${pyhelper}" ]; then
            mv "${pkgdir}/usr/lib/collaboraoffice/program/${pyhelper}" "${pkgdir}/${site_packages}/"
        fi
    done

    # 6. Desktop document templates
    install -dm755 "${pkgdir}/usr/share/templates/.source"
    if [ -d "${srcdir}/core/extras/source/shellnew" ]; then
        install -m644 "${srcdir}/core/extras/source/shellnew"/soffice.* \
            "${pkgdir}/usr/share/templates/.source/" 2>/dev/null || true
    fi

    for pair in "Writer:odt:text" "Calc:ods:spreadsheet" "Impress:odp:presentation"; do
        app=$(echo $pair | cut -d: -f1)
        ext=$(echo $pair | cut -d: -f2)
        type=$(echo $pair | cut -d: -f3)
        sed -e "s/@APP@/${app}/g" -e "s/@EXT@/${ext}/g" -e "s/@TYPE@/${type}/g" \
            "${srcdir}/soffice-template.desktop.in" > "${pkgdir}/usr/share/templates/collaboraoffice.${ext}.desktop"
    done
}

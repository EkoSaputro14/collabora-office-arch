# Collabora Office Native Arch Linux Package

[![Arch Linux Packaging](https://img.shields.io/badge/Arch%20Linux-Packaging-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)
[![Enterprise LTS](https://img.shields.io/badge/Branch-distro%2Fcollabora%2Fco--24.04-blue)](https://github.com/LibreOffice/core/tree/distro/collabora/co-24.04)

Native Arch Linux package (`collabora-office-<version>-x86_64.pkg.tar.zst`) for **Collabora Office Desktop** built 100% from upstream enterprise source code without Flatpak, Snap, AppImage, or containers.

---

## Fitur & Karakteristik Paket

1. **Native Source Build**:
   * Dibangun langsung dari branch enterprise resmi Collabora: `distro/collabora/co-24.04` (Gerrit: `https://gerrit.collaboraoffice.com/core`, Mirror: `https://github.com/LibreOffice/core.git`).
   * Menggunakan toolchain GCC/Clang bawaan Arch Linux dan konfigurasi distro `CPLinux`.
2. **Standard Arch Linux Hierarchy**:
   * Prefix instalasi: `/usr/lib/collaboraoffice`
   * Executable symlinks: `/usr/bin/collaboraoffice`, `/usr/bin/collaboraoffice-writer`, `/usr/bin/collaboraoffice-calc`, `/usr/bin/collaboraoffice-impress`, `/usr/bin/collaboraoffice-draw`, `/usr/bin/collaboraoffice-base`, `/usr/bin/collaboraoffice-math`.
   * Tidak menimpa binary stok `libreoffice`.
3. **Official Collabora Branding**:
   * Splash screen resmi Collabora (`intro.png`, `intro-highres.png`).
   * Dialog About (`about.svg`, `about_inverted.svg`).
   * Ikon aplikasi resmi di `/usr/share/icons/hicolor/`.
4. **Desktop & MIME Integration**:
   * File `.desktop` lengkap untuk Start Center, Writer, Calc, Impress, Draw, Base, dan Math.
   * Asosiasi file dokumen lengkap: `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`, `.odt`, `.ods`, `.odp`, `.odg`, `.odb`, `.pdf`.
   * Template dokumen KDE/GNOME (`.source/soffice.*`).
5. **Modern UI & Colibre Theme**:
   * Antarmuka **NotebookBar** (Ribbon Tabbed) aktif.
   * Paket icon theme **Colibre** dan **Colibre Dark** terpasang secara bawaan.
6. **Native Python UNO**:
   * Integrasi standar Arch Linux ke `site-packages/uno.py` tanpa modifikasi destruktif.

---

## Struktur Direktori Repository

```
collabora-office-arch/
├── PKGBUILD                      # Definisi paket makepkg Arch Linux
├── collabora-office.install      # Post-install hooks (update mime/desktop/icon cache)
├── collaboraoffice.sh            # Environment preset script (profile.d)
├── collaboraoffice.csh           # C-shell environment preset script
├── soffice-template.desktop.in   # Template desktop generator
├── LICENSE                       # Mozilla Public License 2.0
├── README.md                     # Dokumentasi utama
├── branding/                     # Aset visual branding resmi Collabora
├── desktop/                      # File desktop & asosiasi MIME resmi
├── icons/                        # Ikon resolusi tinggi resmi hicolor (16x16 - 512x512 + SVG)
├── patches/                      # Patch teknis kompatibilitas toolchain Arch
├── scripts/                      # Script otomasi build, clean, dan update
│   ├── build.sh                  # Wrapper makepkg
│   ├── clean.sh                  # Pembersih workspace build
│   └── update-version.sh         # Pengecek update branch enterprise Collabora
├── docs/                         # Dokumentasi arsitektur & panduan build
│   ├── ARCHITECTURE.md           # Laporan investigasi arsitektur Collabora Office
│   └── BUILDING.md               # Panduan kebutuhan sistem & optimasi kompilasi
├── testing/                      # Test suite verifikasi paket
│   ├── test-pkg.sh               # Validasi struktur & integritas artifak .pkg.tar.zst
│   └── run-smoke-tests.sh        # Smoke test konversi dokumen & Python UNO
└── .github/workflows/
    └── build.yml                 # CI GitHub Actions (Clean Arch Linux container)
```

---

## Cara Membangun Paket

### 1. Kebutuhan Sistem
* Minimal 8-16 GB RAM (disarankan swap 16 GB jika RAM < 16 GB).
* ~25 GB ruang kosong di disk.
* Paket dasar Arch Linux:
  ```bash
  sudo pacman -Syu --needed base-devel git ccache
  ```

### 2. Eksekusi Build
Jalankan perintah standar `makepkg`:

```bash
# Clone repository ini
git clone https://github.com/<user>/collabora-office-arch.git
cd collabora-office-arch

# Build dan pasang dependensi secara otomatis
makepkg -si
```

Atau jalankan helper script:
```bash
./scripts/build.sh -si
```

### 3. Hasil Build
Hasil kompilasi akan menghasilkan paket native:
```bash
collabora-office-24.04.17.3-1-x86_64.pkg.tar.zst
```

Dapat dipasang atau didistribusikan ke mesin Arch Linux mana pun menggunakan:
```bash
sudo pacman -U collabora-office-24.04.17.3-1-x86_64.pkg.tar.zst
```

---

## Verifikasi & Pengujian

Jalankan script verifikasi setelah paket berhasil dibangun:

```bash
# Validasi struktur file paket sebelum diinstal
./testing/test-pkg.sh

# Smoke test setelah paket terpasang di sistem
./testing/run-smoke-tests.sh
```

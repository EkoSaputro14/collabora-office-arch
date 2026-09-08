# Building Collabora Office Desktop on Arch Linux

## 1. System Requirements

Building Collabora Office from source is a large compilation task comparable to Chromium, LLVM, or GCC.

| Resource | Recommended Minimum | Optimal |
|---|---|---|
| **CPU** | 4 Cores / 8 Threads | 16+ Cores |
| **RAM** | 16 GB (or 8 GB RAM + 16 GB Swap) | 32 GB+ |
| **Disk Space** | 25 GB free space | 50 GB free NVMe SSD |
| **Time** | 1.5 - 3 hours (depending on CPU) | ~30 - 45 mins with ccache |

---

## 2. Prerequisites

Ensure your Arch Linux system is up-to-date and development tools are installed:

```bash
sudo pacman -Syu --needed base-devel git ccache
```

---

## 3. Quick Build

From the root of this repository:

```bash
# Clone the repository
git clone https://github.com/<your-repo>/collabora-office-arch.git
cd collabora-office-arch

# Build and install dependencies automatically
makepkg -si
```

Or use the provided helper script:

```bash
./scripts/build.sh -si
```

---

## 4. Build Optimizations

### ccache Acceleration
To significantly speed up rebuilds and updates, enable `ccache` in your `/etc/makepkg.conf`:

```bash
BUILDENV=(!distcc color !leflags ccache check !sign)
```

Increase your ccache cache size:
```bash
ccache -M 30G
```

### Compiler Flags (makepkg.conf)
Collabora Office uses its own internal parallel LTO handler (`--enable-lto` in `./autogen.sh`). Therefore, keep `options=('!lto')` in PKGBUILD so makepkg does not inject conflicting single-threaded LTO flags.

---

## 5. Post-Installation Verification

Once installed with `sudo pacman -U collabora-office-*.pkg.tar.zst`, run:

```bash
# Verify version
collaboraoffice --version

# Launch Writer with NotebookBar
collaboraoffice-writer

# Test headless conversion
collaboraoffice --headless --convert-to pdf sample.docx
```

---

## 6. Troubleshooting

### Out of Memory (OOM Killer) during linking
If `ld` or `lto1` is killed due to memory exhaustion:
1. Reduce parallelism: `makepkg -s -- MAKEFLAGS="-j4"`
2. Add a temporary swapfile:
   ```bash
   sudo fallocate -l 16G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

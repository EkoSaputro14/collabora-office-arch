# Patches Directory for Collabora Office Arch Linux Packaging

This directory contains technical patches and fixes evaluated during packaging.

---

### Patch List

#### 1. `0001-arch-cflags-fortify-source.patch`
* **Target File**: `solenv/gbuild/platform/com_GCC_defs.mk`
* **Reason**: 
  Arch Linux default `makepkg.conf` sets `-D_FORTIFY_SOURCE=3`. LibreOffice/Collabora Office memory allocation wrappers (specifically `malloc_usable_size` usage in `sal/` and `vcl/`) trigger runtime assertions and compilation failures under fortification level 3. Fortification level 2 is required for stable execution.
* **Source**:
  Derived directly from Arch Linux official `libreoffice-fresh` packaging standard.
* **Upstream / Downstream**:
  Downstream packaging standard for Arch Linux. Also handled dynamically via environment flags in `prepare()` function of `PKGBUILD`.
* **Can be upstreamed?**:
  Upstream LibreOffice Bug tracker issue tdf#152111 tracks FORTIFY_SOURCE=3 compatibility across glibc versions.

---

### Patch Application Policy
In accordance with Arch Linux packaging guidelines, patches are only applied if necessary to adapt upstream enterprise source code to Arch Linux's modern toolchain (GCC 14+, Clang 19+, latest glibc). Upstream code is kept intact as much as possible.

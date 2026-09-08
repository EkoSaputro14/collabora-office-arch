# Collabora Office Desktop Architecture on Arch Linux

## 1. Executive Summary

Collabora Office is the enterprise-hardened distribution of LibreOffice developed by Collabora Productivity Ltd. While LibreOffice is community-focused with rapid release iterations, Collabora Office focuses on long-term enterprise stability, deep Microsoft Office interoperability, regression prevention, and security backports.

This packaging project provides a 100% native Arch Linux package (`collabora-office-<version>-x86_64.pkg.tar.zst`) built directly from Collabora's official enterprise branch without using Flatpak, Snap, AppImage, or containers.

---

## 2. Upstream Relationship & Branch Structure

```
                  ┌──────────────────────────────────────────────┐
                  │ LibreOffice Core Master (upstream dev)       │
                  └──────────────────────┬───────────────────────┘
                                         │
                                         ▼ (Branch points)
                  ┌──────────────────────────────────────────────┐
                  │ LibreOffice 24.4 / 24.8 Core Branches        │
                  └──────────────────────┬───────────────────────┘
                                         │
                                         ▼ (Enterprise Fork & Hardening)
                  ┌──────────────────────────────────────────────┐
                  │ Collabora Enterprise: distro/collabora/co-*  │
                  │ (Gerrit: gerrit.collaboraoffice.com/core)    │
                  │ (Mirror: github.com/LibreOffice/core)        │
                  └──────────────────────┬───────────────────────┘
                                         │
                     ┌───────────────────┴───────────────────┐
                     ▼                                       ▼
          ┌──────────────────────┐               ┌──────────────────────┐
          │ Collabora Online     │               │ Collabora Office     │
          │ (COOL / Cloud / WSD) │               │ Desktop (VCL Native) │
          └──────────────────────┘               └───────────┬──────────┘
                                                             │
                                                             ▼ (Arch Native)
                                                 ┌──────────────────────┐
                                                 │ PKGBUILD (makepkg)   │
                                                 │ /usr/lib/collabora...│
                                                 └──────────────────────┘
```

### Git Repositories
1. **Official Gerrit Code Review**: `https://gerrit.collaboraoffice.com/core`
2. **Official GitHub Mirror**: `https://github.com/LibreOffice/core.git`
3. **Active Enterprise LTS Branch**: `distro/collabora/co-24.04` (Version 24.04.17.x)

---

## 3. Core Differences from Stock LibreOffice

1. **Downstream Patches**:
   Collabora maintains over 2,000 distinct patches on top of upstream LibreOffice, focusing on:
   - High-fidelity Microsoft Office OOXML import/export filters (`.docx`, `.xlsx`, `.pptx`).
   - Native shape handling, SmartArt rendering, and font substitution matrices.
   - Core performance improvements for complex spreadsheet calculations and large slide decks.
2. **Branding Pipeline**:
   - Upstream LibreOffice uses generic document foundation branding.
   - Collabora enterprise branches include official brand assets located in `icon-themes/galaxy/brand_cp/` (splash screens, about dialogs, logos).
   - Packaging activates this natively via `--with-vendor="Collabora Productivity Ltd."` and `--with-branding=icon-themes/galaxy/brand_cp`.
3. **User Interface**:
   - NotebookBar (Ribbon-style Tabbed UI) is fully integrated.
   - Colibre and Colibre Dark icon themes are pre-selected for clean modern aesthetic.

---

## 4. Arch Linux Packaging Design Decisions

### Installation Target: `/usr/lib/collaboraoffice`
* Follows the Arch packaging standard for office suites (`/usr/lib/libreoffice`).
* Files are installed in `/usr/lib/collaboraoffice` with symlinks in `/usr/bin/`:
  - `/usr/bin/collaboraoffice`
  - `/usr/bin/collaboraoffice-writer`
  - `/usr/bin/collaboraoffice-calc`
  - `/usr/bin/collaboraoffice-impress`
  - `/usr/bin/collaboraoffice-draw`
  - `/usr/bin/collaboraoffice-base`
  - `/usr/bin/collaboraoffice-math`
* This allows Collabora Office to run as the primary office suite or side-by-side with stock LibreOffice without binary conflicts.

### Python UNO Integration
Python UNO bridges are installed natively into `/usr/lib/python3.x/site-packages/uno.py` with dynamic `URE_BOOTSTRAP` resolution pointing to `/usr/lib/collaboraoffice/program/fundamentalrc`. This complies with Arch Python packaging guidelines without environment variable hacks.

### Memory Fortification Compatibility
Arch Linux GCC 14+ enables `-D_FORTIFY_SOURCE=3` by default in `makepkg.conf`. The LibreOffice memory allocator (`malloc_usable_size` in `sal` and `vcl`) requires `-D_FORTIFY_SOURCE=2`. The PKGBUILD adjusts this compiler flag during `prepare()`.

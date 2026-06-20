# System Profile

## OS

- **Distro:** CachyOS (rolling release, Arch-based)
- **Kernel:** linux-cachyos (currently 7.0.12-1-cachyos)
- **Boot:** UEFI
- **Display Manager:** plasmalogin (SDDM with Plasma theme)

## Desktop Environments (both on Wayland)

- **Primary:** Hyprland 0.55.4 (compositor/window manager)
- **Secondary:** Plasma 6.6.5 (full desktop environment)
- **Session type:** Wayland
- User can switch between Hyprland and Plasma at login. Both are installed and configured.

### Key Hyprland packages

- hyprland, hypridle, hyprpaper, hyprcursor, xdg-desktop-portal-hyprland
- Hyprland utils: hyprland-guiutils, hyprtoolkit, hyprutils

### Key Plasma packages

- plasma-desktop, plasma-workspace, kwin, kwindowsystem

## Hardware

- **CPU:** AMD Ryzen 5 9600X (6 cores / 12 threads, Zen 5)
- **GPU:** AMD Radeon RX 9060 XT (Navi 44, RDNA 4) + AMD Granite Ridge iGPU
- **RAM:** 30 GB
- **Storage:** 1 TB NVMe SSD (Samsung or equivalent, `/dev/nvme0n1`)

## Filesystem

- **Type:** Btrfs with zstd:1 compression, noatime
- **Layout (subvolumes):**
  - `/` → `@`
  - `/home` → `@home`
  - `/root` → `@root`
  - `/srv` → `@srv`
  - `/var/cache` → `@cache`
  - `/var/tmp` → `@tmp`
  - `/var/log` → `@log`
- **Boot:** separate FAT32 EFI partition at `/boot`
- **Swap:** separate swap partition (UUID 5dc33833-...)

## Package Management

- **Package manager:** pacman (1618 packages installed)
- **AUR helper:** paru
- **No flatpak or snap** — packages installed natively via pacman/paru only

## Constraints & Conventions

- Do **not** install flatpak or snap packages unless explicitly requested.
- Prefer pacman packages over AUR when available.
- For AUR packages, use `paru` as the AUR helper.
- Both Hyprland and Plasma configs may exist simultaneously — check which is active before making changes.
- CachyOS uses its own kernel and some custom repos — do not replace the kernel with mainline unless requested.
- Btrfs snapshots may or may not be configured — check before assuming snapshot rollback is available.

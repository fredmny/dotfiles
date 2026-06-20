---
description: "Load system profile context for help with OS, DE, or hardware tweaks"
---

## System Profile

- **OS:** CachyOS (rolling, Arch-based), kernel `linux-cachyos` (check with `uname -r`)
- **DEs:** Hyprland + Plasma, both on **Wayland** (switchable at login via plasmalogin/SDDM)
  - Check DE versions at runtime: `pacman -Q hyprland plasma-desktop`
  - Detect active session: check `$XDG_CURRENT_DESKTOP` or `$HYPRLAND_INSTANCE_SIGNATURE`
- **CPU:** AMD Ryzen 5 9600X (6c/12t, Zen 5)
- **GPU:** AMD Radeon RX 9060 XT (Navi 44, RDNA 4) + AMD Granite Ridge iGPU
- **RAM:** 30 GB
- **Storage:** 1 TB NVMe, **Btrfs** with zstd:1 + noatime, subvolumes: @, @home, @root, @srv, @cache, @tmp, @log
- **Boot:** UEFI, separate FAT32 `/boot` partition, separate swap partition
- **Pkg mgmt:** pacman + paru + yay (AUR), ~1600 pkgs, **no flatpak/snap**

## Rules

- Prefer pacman over AUR. Use `yay` as the default AUR helper unless told otherwise.
- Never install flatpak or snap packages unless explicitly asked.
- Always query current package versions at runtime before making changes — don't rely on stale data, as this is a rolling distro.
- Check which DE is active before touching Hyprland or Plasma configs.
- Do not replace the cachyos kernel with mainline unless asked.
- Check for btrfs snapshots before assuming rollback is available.

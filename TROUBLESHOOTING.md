# Troubleshooting Notes

## Boot Hang (CachyOS + Limine + Plymouth + RX 9060 XT)

### Symptoms
- System hangs at startup during the boot splash / loading phase
- Requires forceful restart (holding power button or pressing it once)
- Happens intermittently — sometimes 2-3 failed boots before a successful one

### Diagnosis
Run these commands to check for the issue:
```bash
# List recent boots (look for very short-lived boots ~1min)
journalctl --list-boots

# Check failed boot logs (replace -2 with the relevant boot index)
journalctl -b -2 -p 3 --no-pager
journalctl -b -2 --no-pager | grep -i plymouth
journalctl -b -2 --no-pager | grep -i "Device or resource busy"
```

### Root Cause
**Plymouth (boot splash) hangs during shutdown**, preventing the GPU from being handed over to the display manager (plasmalogin/SDDM).

Sequence of events:
1. Boot starts with `simple-framebuffer` (simpledrm) as early framebuffer
2. Plymouth grabs DRM master from simpledrm
3. `amdgpu` driver initializes both GPUs (dGPU RX 9060 XT on minor 1, iGPU on minor 0)
4. `plymouth-quit.service` starts (~6s into boot)
5. **Plymouth never responds to quit** — hangs for full 20s timeout
6. After timeout, `kwin_wayland` fails to open `/dev/dri/card1` with "Device or resource busy"
7. Login screen shows "no outputs - creating placeholder screen"

Key evidence:
- `plymouth-quit.service: start operation timed out. Terminating.`
- `Failed to start Terminate Plymouth Boot Screen.`
- `kwin_wayland: Failed to open /dev/dri/card1 device (Device or resource busy)`

Contributing factors:
- RX 9060 XT (Navi 44 / RDNA 4) — very new GPU, immature kernel/firmware support
- Hybrid AMD graphics (iGPU + dGPU) via vga_switcheroo
- Race condition between simpledrm → amdgpu handoff and Plymouth

Not the cause:
- USB enumeration errors on port `5-2.2.3` — consistent across all boots, unrelated

### Fix Applied
Removed `splash` from kernel command line to disable Plymouth.

```bash
# Edit /etc/default/limine — remove 'splash' from KERNEL_CMDLINE
sudo sed -i 's/ nowatchdog splash rw / nowatchdog rw /' /etc/default/limine

# Regenerate Limine boot entries
sudo linine-update
```

This disables the graphical boot animation. Zero impact on system functionality — Plymouth is purely cosmetic.

### Hardware Summary
| Component | Details |
|-----------|---------|
| Motherboard | ASUS TUF GAMING B650E-E WIFI (BIOS 3827, 2026-02-06) |
| CPU | AMD Ryzen 9000 (Granite Ridge) + Radeon iGPU (0x13c0) |
| dGPU | AMD Radeon RX 9060 XT / Navi 44 (0x7590, 16GB) |
| Kernel | 7.0.10-2-cachyos |
| Bootloader | Limine 12.3.2 |
| Filesystem | Btrfs (subvol=@) |
| Display | card1 (dGPU): DP-1 + HDMI-A-1 connected, card0 (iGPU): nothing connected |

### If the hang returns
Try these kernel parameters (append to KERNEL_CMDLINE in `/etc/default/limine`):
- `plymouth.use-simpledrm` — improve simpledrm handoff
- Remove `quiet` too — see boot messages for more clues
- `amdgpu.sg_display=0` — disable scatter/gather display

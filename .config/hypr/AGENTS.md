# Hyprland Config

## Lua API

Hyprland uses the **Lua API** for configuration (since 0.55). All config
changes must use the Lua-based `hl.*` API, not the old hyprlang syntax.

Use `hyprctl eval "..."` to execute Lua code at runtime. The old `hyprctl
keyword` does not work with the Lua config parser.

## Documentation

- Official Wiki (Lua config): https://wiki.hypr.land/Configuring/

## Pywal + OpenRGB integration

`rotate-wallpaper.sh` picks a random wallpaper, sets it via hyprpaper, runs
`wal` to regenerate a 16-colour palette in `~/.cache/wal/colors.json`, then
calls `openrgb-wal.sh &` at the end.

### openrgb-wal.sh

The motherboard is driven with **one flat per-LED colour write**:

```
openrgb -d "ASUS" -m Direct -c c1,c2,...,cN
```

Do **not** use `-z`/`-sz` or the profile loader for the motherboard:

- `-z`/`-sz` resets the channel state and leaves the LEDs **off**.  `-sz` also
  rewrites `Configuration.json`, which can wedge the controller until it is
  reset (replug / power cycle).
- The profile loader skips the mode block because the saved mode list (9
  modes, from OpenRGB 1.0) no longer matches the live controller (19 modes in
  1.1), so it never sets `Direct` mode.  It only copies colours and calls
  `UpdateLEDs()`.

The flat list must match the controller's LED count exactly, so the zone
layout is read from the live device (`openrgb -sp __layout`) instead of being
hardcoded.  The script falls back to `16,8,7` if the capture fails.

**Mouse:** the G502 is exposed twice (wired HID++ interface + Lightspeed
receiver).  `openrgb -d "Mouse" -m Direct -c <hex>` applies to every matching
device, so both get the accent colour.

**GPU (`Sapphire Radeon RX 9060 XT Nitro+`):** a single `GPU LED` in `Static`
mode.  It is **not** stored in the profile: the Nitro Glow does not round-trip
its colour bytes through profiles (each load/save rotates them, e.g.
`0x123456` → `0x345612` → `0x563412`), so profile colours would drift.  The
script sets it directly: `openrgb -d "Sapphire" -m Static -c <hex>`.  It reuses
the mouse accent colour.  Its brightness register (`0x3E`) is never written by
OpenRGB (the V3 controller exposes no brightness mode).

**pywal.json:** the script also rewrites `profiles/pywal.json` from the live
capture (current 19-mode list, correct zone sizes, GPU dropped) so the GUI
autostart and `openrgb.service` cannot overwrite the direct write with last
session's colours.

**Colour pipeline:**
1. Read `colors.json`, exclude `color0` (dark bg) and `color7` (fg).
2. Deduplicate (pywal often copies color1→color9 etc.).
3. Keep only **chromatic** entries (HLS saturation ≥ 0.20).  Near-greys have
   an essentially arbitrary hue, so boosting them invents colours that are not
   in the image — that is what made a monochrome wallpaper produce a rainbow.
   If fewer than 2 survive, fall back to the full list.
4. `led_transform()` — luminance into 0.30–0.60, saturation × 1.35.  No
   saturation floor (see step 3).
5. Pick A = best score (saturation×0.7 + luminance-bonus×0.3).  Pick B = the
   chromatic colour with the best `saturation×0.6 + min(hue_dist, 0.30)×1.2`,
   skipping hues closer than 0.04; if none qualifies, B = A (flat colour).
6. `circular_gradient()` — **HSL** interpolation along the shortest hue path,
   wrapping A→B→A so the last LED neighbours the first.  HSL keeps saturation
   constant; RGB interpolation desaturates in the middle (pink→yellow via a
   washed-out salmon), which is what made the gradient look pale.  The hue
   distance cap in step 5 keeps the sweep inside the wallpaper's hues.
7. Mouse and GPU get colour A.

**Autostart:** `~/.config/autostart/OpenRGB.desktop` and the user unit
`~/.config/systemd/user/openrgb.service` both load the `pywal` profile at
login.  `OpenRGB.json` → `ProfileManager` (`open_profile`, `resume_profile`,
`service_startup_profile`) also points at `pywal`.  Note `OpenRGB.json` →
`AutoStart` has **no** `profile` key, so the GUI itself does not load a profile
from that path.

### Debugging notes

- `openrgb -sp <name>` in a **separate process** always reports the fresh
  controller state (all-zero colours), not the hardware state.  To inspect
  what a load actually did, load and save in the *same* invocation:
  `openrgb -p pywal -sp after` then read `after.json`.
- The GPU's I²C registers can be read directly: bus from
  `openrgb -ld` (`/dev/i2c-6`), address `0x28`, `0x1A`/`0x1B`/`0x1C` = R/G/B,
  `0x10` = mode (`0x06` = Static), `0x0F` = external control.
- Two OpenRGB GUI instances (autostart + a manually launched one) both write
  to the hardware and will fight each other.

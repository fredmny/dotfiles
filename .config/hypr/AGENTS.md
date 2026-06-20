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

The ASUS Aura addressable controller (HID) does **not** reliably accept
per-LED colour writes via the openrgb CLI.  The CLI's `-sp` saves all-zero
colours.  Instead, the script **binary-patches** the profile file and loads it.

**Template:** `~/.config/OpenRGB/profile_01.orp` (GUI-created, working Direct-mode
structure).  Patched output: `~/.config/OpenRGB/pywal.orp`.

**Binary profile format** (`profile_01.orp` / `pywal.orp`):
- Header: `OPENRGB_PROFILE`, then device/mode/zone metadata.
- All 31 motherboard LEDs stored consecutively at offset `0x745`.
- Per LED: 4 bytes `RR GG BB 00` (R, G, B, zero-padding).
- Zone layout: 0=Aura Addr 1 (16 LEDs, idx 0–15), 1=Aura Addr 2 (8 LEDs,
  idx 16–23), 2=Aura Addr 3 (7 LEDs, idx 24–30 — **left untouched**).
- Mouse LEDs found by locating `Logo LED\x00` marker, then skipping
  9 (name) + 4 (zone info) + 2 (count) bytes to reach colour data.  Same
  `RR GG BB 00` format.

**Colour pipeline:**
1. Read `colors.json`, exclude `color0` (dark bg) and `color7` (fg).
2. Deduplicate (pywal often copies color1→color9 etc.).
3. `led_transform()` — push each colour into the LED sweet spot:
   luminance 0.25–0.58, saturation ≥0.45 × 1.4.
4. Sort by saturation descending, pick top 2 with maximally different hues.
5. `circular_gradient()` — HSL interpolation (shortest hue path) over the
   zone's LED count, wrapping A→B→A so the last LED neighbours the first.
6. Mouse gets the single best colour (score = saturation×0.7 + luminance-bonus×0.3).

**Autostart:** `~/.config/autostart/OpenRGB.desktop` and
`~/.config/OpenRGB/OpenRGB.json` (`AutoStart.profile` + `autoload_profiles`)
all point to `pywal`, not `profile_01`.  OpenRGB loads `pywal.orp` at login
(last session's colours), then `openrgb-wal.sh` updates it when the wallpaper
rotates.


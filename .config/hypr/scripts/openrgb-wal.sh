#!/bin/bash
# Set RGB device (fans, mouse, housing LEDs) colors from pywal palette.
# Called by rotate-wallpaper.sh after wal regenerates colors.
#
# The ASUS Aura addressable controller does not reliably accept per-LED color
# writes via the openrgb CLI.  Instead we binary-patch the profile file and
# load it.  profile_01 (the user's existing working profile) is used as the
# template because it already has the correct device structure with Direct
# mode active and non-zero placeholder colors.

WAL_JSON="$HOME/.cache/wal/colors.json"
PROFILE_DIR="$HOME/.config/OpenRGB"
TEMPLATE="$PROFILE_DIR/profile_01.orp"
OUTFILE="$PROFILE_DIR/pywal.orp"

# Bail silently if openrgb is missing
command -v openrgb >/dev/null 2>&1 || exit 0

# Bail if wal hasn't generated colors yet
[ -f "$WAL_JSON" ] || exit 0

# Bail if template profile doesn't exist
[ -f "$TEMPLATE" ] || exit 0

python3 -c "
import json, struct, colorsys

# ── Read pywal colours ──────────────────────────────────────────────
with open('$WAL_JSON') as f:
    wal = json.load(f)

c = wal['colors']

def hex_to_rgb(h):
    return int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255

def rgb_to_hex(r, g, b):
    return f'{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}'

def byte_rgb(h):
    return int(h[0:2],16), int(h[2:4],16), int(h[4:6],16)

def led_transform(hexcol):
    \"\"\"Transform a pywal colour into something vivid on LED fans.
    LEDs emit light directly, so dark=off and pastel=white-washed.
    We push luminance into the 0.25–0.58 sweet spot and amplify saturation.\"\"\"
    r, g, b = hex_to_rgb(hexcol)
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    # Push saturation up — LEDs need it to avoid looking grey
    s = min(1.0, max(s, 0.45) * 1.4)
    # Pull luminance toward the visible LED sweet spot
    if l < 0.18:
        l = 0.25  # lift near-black so the LED actually glows
    elif l > 0.62:
        l = 0.58  # tame near-white so it doesn't look washed out
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return rgb_to_hex(r, g, b)

# Deduplicate colours (pywal often duplicates color1=color9, etc.)
# Exclude color0 (dark background) and color7 (foreground) — they are
# not meant to be decorative accent colours on LED hardware.
seen = set()
all_hex = []
skip = {'color0', 'color7'}
for k in sorted(c.keys()):
    if k in skip:
        continue
    h = c[k].lstrip('#')
    if h not in seen:
        seen.add(h)
        all_hex.append(h)

# Fallback: if we excluded too many, relax the skip
if len(all_hex) < 5:
    all_hex = []
    seen = set()
    for k in sorted(c.keys()):
        h = c[k].lstrip('#')
        if h not in seen:
            seen.add(h)
            all_hex.append(h)

# Transform all colours for LED output, sort by saturation descending
transformed = [(led_transform(h), h) for h in all_hex]
def get_sat(hexcol):
    r, g, b = hex_to_rgb(hexcol)
    return colorsys.rgb_to_hls(r, g, b)[2]
transformed.sort(key=lambda x: get_sat(x[0]), reverse=True)
top = [t for t, _ in transformed]

# ── Pick 2 colours for a smooth circular gradient ─────────────────
# Colour A: most saturated.  Colour B: most saturated *with a
# noticeably different hue* so the gradient is visible.
def hue_dist(h1, h2):
    d = abs(h1 - h2)
    return min(d, 1.0 - d)

color_a = top[0]
h_a = colorsys.rgb_to_hls(*hex_to_rgb(color_a))[0]

best_b, best_score = top[1], -1
for c in top[1:]:
    h_c = colorsys.rgb_to_hls(*hex_to_rgb(c))[0]
    s_c = colorsys.rgb_to_hls(*hex_to_rgb(c))[2]
    score = hue_dist(h_a, h_c) * 0.7 + s_c * 0.3
    if score > best_score:
        best_score = score
        best_b = c
color_b = best_b

def interpolate_hsl(c1, c2, t):
    \"\"\"HSL interpolation — shortest hue path, t in [0,1].\"\"\"
    r1, g1, b1 = hex_to_rgb(c1)
    r2, g2, b2 = hex_to_rgb(c2)
    h1, l1, s1 = colorsys.rgb_to_hls(r1, g1, b1)
    h2, l2, s2 = colorsys.rgb_to_hls(r2, g2, b2)
    if abs(h1 - h2) > 0.5:
        if h2 > h1: h1 += 1.0
        else:       h2 += 1.0
    h = (h1 + (h2 - h1) * t) % 1.0
    l = l1 + (l2 - l1) * t
    s = s1 + (s2 - s1) * t
    return rgb_to_hex(*colorsys.hls_to_rgb(h, l, s))

def circular_gradient(c1, c2, n_leds):
    \"\"\"Smooth c1→c2→c1 gradient across n_leds in a circle.
    LED 0 = c1,  LED n/2 = c2,  LED n-1 ≈ c1 (wraps back).\"\"\"
    out = []
    for i in range(n_leds):
        t = i / n_leds          # position on circle [0, 1)
        if t <= 0.5:
            out.append(interpolate_hsl(c1, c2, t * 2))
        else:
            out.append(interpolate_hsl(c2, c1, (t - 0.5) * 2))
    return out

# Mouse: best single colour (bright + saturated)
def mouse_score(h):
    r, g, b = hex_to_rgb(h)
    _, l, s = colorsys.rgb_to_hls(r, g, b)
    lum_bonus = 1.0 - abs(l - 0.45) * 2
    return s * 0.7 + lum_bonus * 0.3
mouse_hex = max(top, key=mouse_score)

# ── Read template profile ───────────────────────────────────────────
with open('$TEMPLATE', 'rb') as f:
    data = bytearray(f.read())

# Motherboard addressable LEDs — all 31 stored consecutively at 0x745
#   Zone 0:  Aura Addressable 1  — 16 LEDs  (indices  0–15)
#   Zone 1:  Aura Addressable 2  —  8 LEDs  (indices 16–23)
#   Zone 2:  Aura Addressable 3  —  7 LEDs  (indices 24–30) — left as-is
MB_OFFSET = 0x745

# Zone 0 (16 LEDs): smooth A↔B circular gradient
z0 = circular_gradient(color_a, color_b, 16)
for i, h in enumerate(z0):
    r, g, b = byte_rgb(h)
    off = MB_OFFSET + i * 4
    data[off:off+4] = struct.pack('BBBB', r, g, b, 0)

# Zone 1 (8 LEDs): same gradient, fewer points
z1 = circular_gradient(color_a, color_b, 8)
for i, h in enumerate(z1):
    r, g, b = byte_rgb(h)
    off = MB_OFFSET + (16 + i) * 4
    data[off:off+4] = struct.pack('BBBB', r, g, b, 0)

# Mouse (Logitech G502)
#   Two LEDs: Primary LED + Logo LED
#   Marker: 'Logo LED\\x00' string; colour data follows zone info + count
logo_pos = data.find(b'Logo LED\x00')
if logo_pos > 0:
    mouse_start = logo_pos + 9 + 4 + 2
    mouse_count = int.from_bytes(data[mouse_start-2:mouse_start], 'little')
    r, g, b = byte_rgb(mouse_hex)
    for i in range(mouse_count):
        off = mouse_start + i * 4
        data[off:off+4] = struct.pack('BBBB', r, g, b, 0)

# ── Write patched profile ──────────────────────────────────────────
import os
os.makedirs('$PROFILE_DIR', exist_ok=True)
with open('$OUTFILE', 'wb') as f:
    f.write(data)
"

# Load the freshly-written profile (auto-appends .orp)
openrgb -p pywal 2>/dev/null

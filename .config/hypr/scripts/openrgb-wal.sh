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

python3 - "$WAL_JSON" "$TEMPLATE" "$OUTFILE" "$PROFILE_DIR" << 'PYEOF'
import json, struct, colorsys, sys, os

wal_json, template, outfile, profile_dir = sys.argv[1:]

with open(wal_json) as f:
    c = json.load(f)['colors']

# ── Helpers ─────────────────────────────────────────────────────────
def hex_to_rgb(h):
    return int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255
def rgb_to_hex(r,g,b):
    return f'{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}'
def byte_rgb(h):
    return int(h[0:2],16), int(h[2:4],16), int(h[4:6],16)
def hue_dist(h1,h2):
    d = abs(h1-h2)
    return min(d, 1.0-d)

# ── LED colour transform ────────────────────────────────────────────
def led_transform(hexcol):
    r,g,b = hex_to_rgb(hexcol)
    h,l,s = colorsys.rgb_to_hls(r,g,b)
    s = min(1.0, max(s, 0.45) * 1.4)
    if l < 0.18:    l = 0.25
    elif l > 0.62:  l = 0.58
    return rgb_to_hex(*colorsys.hls_to_rgb(h,l,s))

# ── HSL interpolation ───────────────────────────────────────────────
def interpolate_hsl(c1, c2, t):
    r1,g1,b1 = hex_to_rgb(c1)
    r2,g2,b2 = hex_to_rgb(c2)
    h1,l1,s1 = colorsys.rgb_to_hls(r1,g1,b1)
    h2,l2,s2 = colorsys.rgb_to_hls(r2,g2,b2)
    if abs(h1-h2) > 0.5:
        if h2 > h1: h1 += 1.0
        else:       h2 += 1.0
    h = (h1 + (h2 - h1) * t) % 1.0
    l = l1 + (l2 - l1) * t
    s = s1 + (s2 - s1) * t
    return rgb_to_hex(*colorsys.hls_to_rgb(h,l,s))

def circular_gradient(c1, c2, n):
    out = []
    for i in range(n):
        t = i / n
        if t <= 0.5: out.append(interpolate_hsl(c1, c2, t*2))
        else:        out.append(interpolate_hsl(c2, c1, (t-0.5)*2))
    return out

# ── Pick top 2 colours ──────────────────────────────────────────────
seen = set()
all_hex = []
skip = {'color0', 'color7'}
for k in sorted(c.keys()):
    if k in skip: continue
    h = c[k].lstrip('#')
    if h not in seen:
        seen.add(h)
        all_hex.append(h)
if len(all_hex) < 5:
    all_hex = list({c[k].lstrip('#') for k in c})

transformed = [(led_transform(h), h) for h in all_hex]
transformed.sort(key=lambda x: colorsys.rgb_to_hls(*hex_to_rgb(x[0]))[2], reverse=True)
top = [t for t,_ in transformed]

color_a = top[0]
h_a = colorsys.rgb_to_hls(*hex_to_rgb(color_a))[0]
best_b, best_score = top[1], -1
for col in top[1:]:
    h_c = colorsys.rgb_to_hls(*hex_to_rgb(col))[0]
    s_c = colorsys.rgb_to_hls(*hex_to_rgb(col))[2]
    score = hue_dist(h_a, h_c) * 0.7 + s_c * 0.3
    if score > best_score:
        best_score = score
        best_b = col
color_b = best_b

# Mouse colour
def mouse_score(h):
    _, l, s = colorsys.rgb_to_hls(*hex_to_rgb(h))
    return s * 0.7 + (1.0 - abs(l - 0.45) * 2) * 0.3
mouse_hex = max(top, key=mouse_score)

# ── Binary-patch ASUS + mouse profile ───────────────────────────────
with open(template, 'rb') as f:
    data = bytearray(f.read())

MB_OFFSET = 0x745

z0 = circular_gradient(color_a, color_b, 16)
for i, h in enumerate(z0):
    r,g,b = byte_rgb(h)
    off = MB_OFFSET + i*4
    data[off:off+4] = struct.pack('BBBB', r, g, b, 0)

z1 = circular_gradient(color_a, color_b, 8)
for i, h in enumerate(z1):
    r,g,b = byte_rgb(h)
    off = MB_OFFSET + (16+i)*4
    data[off:off+4] = struct.pack('BBBB', r, g, b, 0)

logo_pos = data.find(b'Logo LED\x00')
if logo_pos > 0:
    ms = logo_pos + 9 + 4 + 2
    mc = int.from_bytes(data[ms-2:ms], 'little')
    r,g,b = byte_rgb(mouse_hex)
    for i in range(mc):
        off = ms + i*4
        data[off:off+4] = struct.pack('BBBB', r, g, b, 0)

os.makedirs(profile_dir, exist_ok=True)
with open(outfile, 'wb') as f:
    f.write(data)
PYEOF

# Load the freshly-written profile (auto-appends .orp)
openrgb -p pywal 2>/dev/null

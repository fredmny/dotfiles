#!/bin/bash
# Set RGB device (fans, mouse, housing LEDs) colours from the pywal palette.
# Called by rotate-wallpaper.sh after wal regenerates colours.
#
# How the ASUS Aura controller is driven
# --------------------------------------
# A single flat per-LED colour write:
#
#     openrgb -d "ASUS" -m Direct -c c1,c2,...,cN
#
# Do NOT use `-z`/`-sz` or the profile loader:
#
#   * `-z`/`-sz` resets the channel state and leaves the LEDs off (and
#     `-sz` rewrites Configuration.json, which can wedge the controller).
#   * The profile loader skips the mode block because the saved mode list
#     (9 modes, from OpenRGB 1.0) no longer matches the live controller
#     (19 modes in 1.1), so it never sets Direct mode.
#
# The flat colour list must match the controller's LED count exactly, so the
# zone layout is read from the live device instead of being hardcoded.

WAL_JSON="$HOME/.cache/wal/colors.json"
PROFILES_DIR="$HOME/.config/OpenRGB/profiles"
LAYOUT="$PROFILES_DIR/__layout.json"

# Bail silently if openrgb is missing
command -v openrgb >/dev/null 2>&1 || exit 0

# Bail if wal hasn't generated colors yet
[ -f "$WAL_JSON" ] || exit 0

# Capture the live zone layout (names + LED counts).  This is only used to
# size the flat colour list; the colours in the saved profile are ignored.
openrgb -sp __layout >/dev/null 2>&1

OUT=$(python3 - "$WAL_JSON" "$LAYOUT" << 'PYEOF'
import json, colorsys, sys, os

wal_json, layout_path = sys.argv[1:]

with open(wal_json) as f:
    c = json.load(f)['colors']

# ── Zone layout ─────────────────────────────────────────────────────
# Fall back to the known B650E-E layout if the live capture failed.
sizes = [16, 8, 7]
try:
    with open(layout_path) as f:
        prof = json.load(f)
    for ctrl in prof['controllers']:
        if 'ASUS' in ctrl.get('name', ''):
            sizes = [z['leds_count'] for z in ctrl['zones']]
            break
except Exception:
    pass

# ── Helpers ─────────────────────────────────────────────────────────
def hex_to_rgb(h):
    return int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255
def rgb_to_hex(r,g,b):
    return f'{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}'
def hue_dist(h1,h2):
    d = abs(h1-h2)
    return min(d, 1.0-d)

# ── LED colour transform ────────────────────────────────────────────
# LEDs emit light directly, so dark = off and pastel = washed out.  Push
# luminance into the 0.30-0.60 sweet spot and boost saturation a little.
# NOTE: never force a saturation floor here.  A near-grey palette entry
# (e.g. the greys pywal pulls out of a monochrome wallpaper) has an
# essentially arbitrary hue, so forcing saturation on it invents a vivid
# colour that is nowhere in the image.
def led_transform(hexcol):
    r,g,b = hex_to_rgb(hexcol)
    h,l,s = colorsys.rgb_to_hls(r,g,b)
    s = min(1.0, s * 1.35)
    if l < 0.30:    l = 0.30
    elif l > 0.60:  l = 0.60
    return rgb_to_hex(*colorsys.hls_to_rgb(h,l,s))

# ── HSL interpolation ───────────────────────────────────────────────
# Interpolate in HSL along the shortest hue path.  RGB interpolation
# between two saturated colours of different hue desaturates in the
# middle (pink -> yellow via a washed-out salmon), which is what made the
# gradient look pale.  HSL keeps saturation constant, so the sweep stays
# vivid.  The hue distance between A and B is capped when picking B, so
# the sweep cannot wander into hues the wallpaper does not contain.
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

# ── Pick 2 colours ──────────────────────────────────────────────────
# Only consider colours that are actually chromatic in the source image.
# Desaturated entries are dropped so the LEDs cannot show a hue the
# wallpaper does not have; a monochrome wallpaper therefore ends up with
# a single (near-neutral) colour instead of a rainbow.
seen = set()
cands = []
skip = {'color0', 'color7'}
for k in sorted(c.keys()):
    if k in skip: continue
    h = c[k].lstrip('#')
    if h in seen: continue
    seen.add(h)
    r,g,b = hex_to_rgb(h)
    hh,l,s = colorsys.rgb_to_hls(r,g,b)
    cands.append({'hex': h, 'h': hh, 'l': l, 's': s})

chromatic = [x for x in cands if x['s'] >= 0.20]
if len(chromatic) < 2:
    chromatic = cands

def led_score(x):
    return x['s'] * 0.7 + (1.0 - abs(x['l'] - 0.45) * 2) * 0.3

color_a = max(chromatic, key=led_score)

# Colour B: a second chromatic colour with a visibly different hue, but
# not so far away that the gradient sweeps through unrelated hues.
color_b = color_a
best_score = -1
for x in chromatic:
    if x is color_a: continue
    d = hue_dist(color_a['h'], x['h'])
    if d < 0.04: continue
    score = x['s'] * 0.6 + min(d, 0.30) * 1.2
    if score > best_score:
        best_score = score
        color_b = x

color_a = led_transform(color_a['hex'])
color_b = led_transform(color_b['hex'])

# Mouse / GPU accent: the single best colour
mouse_hex = color_a

# ── Build the flat per-LED colour list ──────────────────────────────
flat = []
for n in sizes:
    flat.extend(circular_gradient(color_a, color_b, n))

# ── Refresh pywal.json from the live capture ────────────────────────
# The GUI autostart and openrgb.service both load the "pywal" profile at
# login.  If that profile still holds last session's colours it can
# overwrite the direct write above, so rewrite it from the live capture
# (which has the current 19-mode list and correct zone sizes) and drop the
# GPU, whose colour does not round-trip through profiles.
try:
    with open(layout_path) as f:
        prof = json.load(f)

    keep = []
    for ctrl in prof['controllers']:
        name = ctrl.get('name', '')
        if 'Sapphire' in name:
            continue
        if 'ASUS' in name:
            ctrl['colors'] = [int(h, 16) for h in flat]
        elif 'Mouse' in name:
            ctrl['colors'] = [int(mouse_hex, 16)] * len(ctrl['colors'])
        else:
            keep.append(ctrl)
            continue
        for i, m in enumerate(ctrl.get('modes', [])):
            if m.get('name') == 'Direct':
                ctrl['active_mode'] = i
                break
        keep.append(ctrl)

    prof['controllers'] = keep
    prof['profile_name'] = 'pywal'
    with open(os.path.join(os.path.dirname(layout_path), 'pywal.json'), 'w') as f:
        json.dump(prof, f, indent=4)
except Exception:
    pass

print(','.join(flat))
print(mouse_hex)
PYEOF
)

MB_COLORS=$(printf '%s\n' "$OUT" | sed -n 1p)
ACCENT_HEX=$(printf '%s\n' "$OUT" | sed -n 2p)

# Motherboard: one flat per-LED write.  No -z, no profile.
[ -n "$MB_COLORS" ] && openrgb -d "ASUS" -m Direct -c "$MB_COLORS" 2>/dev/null

# Mouse: the G502 is exposed twice (wired HID++ interface + Lightspeed
# receiver); -d "Mouse" applies to every matching device.
[ -n "$ACCENT_HEX" ] && openrgb -d "Mouse" -m Direct -c "$ACCENT_HEX" 2>/dev/null

# GPU: the Sapphire Nitro Glow does not round-trip its colour bytes through
# profiles, so set it directly.  It only has one LED, so a single colour.
[ -n "$ACCENT_HEX" ] && openrgb -d "Sapphire" -m Static -c "$ACCENT_HEX" 2>/dev/null

# Clean up the layout capture
rm -f "$LAYOUT"

exit 0

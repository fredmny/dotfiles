# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from typing import List  # noqa: F401

import os
from libqtile import bar, layout, widget, qtile
from libqtile.config import Click, Drag, Group, Key, Screen, KeyChord
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

# Load script to read colors from pywal
import pywal_colors
colors = pywal_colors.colors

mod = "mod1"
terminal = guess_terminal()

keys = [
    # Switch between windows in current stack pane
    #Key([mod], "k", lazy.layout.down()),
    #Key([mod], "j", lazy.layout.up()),

    # Move windows up or down in current stack
    #Key([mod, "control"], "k", lazy.layout.shuffle_down()),
    #Key([mod, "control"], "j", lazy.layout.shuffle_up()),

    # Switch window focus to other pane(s) of stack
    # Key([mod], "space", lazy.layout.next()),

    # Swap panes of split stack
    Key([mod, "shift"], "space", lazy.layout.rotate()),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split()),
    Key([mod], "Return", lazy.spawn("termite")),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout()),
    Key([mod], "w", lazy.window.kill()),

    Key([mod, "control"], "r", lazy.restart()),
    Key([mod, "control"], "q", lazy.shutdown()),
    Key([mod], "r", lazy.spawncmd()),
    Key(["mod4"], "space", lazy.spawn("rofi -show drun")),

    ### Custom Keybinds for bsp layout ###
    Key([mod], "j", lazy.layout.down()),
    Key([mod], "k", lazy.layout.up()),
    Key([mod], "h", lazy.layout.left()),
    Key([mod], "l", lazy.layout.right()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "h", lazy.layout.shuffle_left()),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right()),
    Key([mod, "mod4"], "j", lazy.layout.flip_down()),
    Key([mod, "mod4"], "k", lazy.layout.flip_up()),
    Key([mod, "mod4"], "h", lazy.layout.flip_left()),
    Key([mod, "mod4"], "l", lazy.layout.flip_right()),
    Key([mod, "control"], "j", lazy.layout.grow_down()),
    Key([mod, "control"], "k", lazy.layout.grow_up()),
    Key([mod, "control"], "h", lazy.layout.grow_left()),
    Key([mod, "control"], "l", lazy.layout.grow_right()),
    Key([mod, "shift"], "n", lazy.layout.normalize()),
    Key([mod], "o", lazy.layout.maximize()),

    # Change to other screen
    Key([mod], "u",      lazy.to_screen(2)),
    Key([mod], "i",      lazy.to_screen(1)),
    Key([mod], "y",      lazy.to_screen(0)),
    
    # Change the volume if our keyboard has keys
    Key(
        [], "XF86AudioRaiseVolume",
        lazy.spawn("amixer -c 0 -q set Master 2dB+")
    ),
    Key(
        [], "XF86AudioLowerVolume",
        lazy.spawn("amixer -c 0 -q set Master 2dB-")
    ),
    Key(
        [], "XF86AudioMute",
        lazy.spawn("amixer -c 0 -q set Master toggle")
    ),

    # Commands to control spt spotify player
    Key(
        [], "XF86AudioPlay",
        lazy.spawn("spt playback -t"),
        desc='Play/pause music on spt (Spotify)'
    ),

    Key(
        [], "XF86AudioPrev",
        lazy.spawn("spt playback -p"),
        desc='Play previous song on spt (Spotify)'
    ),

    Key(
        [], "XF86AudioNext",
        lazy.spawn("spt playback -n"),
        desc='Play next song on spt (Spotify)'
    ),

    # Change screen brightness
    Key(
        [], "XF86MonBrightnessUp", 
        lazy.spawn("xbacklight -inc 10")
    ),

    Key(
        [], "XF86MonBrightnessDown", 
        lazy.spawn("xbacklight -dec 10")
    ),

    # Keyboard Shortcuts to start applications
    Key([mod], "v", lazy.spawn("code")),
    Key([mod], "q", lazy.spawn("qutebrowser")),

    # Control floating windows
    Key([mod], "f", lazy.window.toggle_floating(), desc='toggle floating'),
    Key([mod], "p", 
        lazy.window.set_size_floating(448, 252),
        lazy.window.set_position_floating(1920+1920-448-10, 1080-252-40),
        desc='Set position for video player floating window'
    ),

    # Launchpad for rofi scripts using ctrl+space followed by 'key'
    KeyChord([mod], "space", [
        Key([], "f",
            # The `os.path.expanduser` is necessary to identify `~` as the $HOME path
            lazy.spawn(os.path.expanduser("~/.config/rofi/scripts/rofi-fontawesome")),
            desc="Select font-awesome icon"
            ),
        Key([], "e",
            lazy.spawn("rofi -show emoji -modi emoji"),
            desc="Emoji Selector"
            ),
        Key([], "c",
            lazy.spawn("rofi -show calc -modi calc -no-show-match -no-sort"),
            desc="Calculator"
            ),
        ])
]

# Default Layout Variable
def_layout = "bsp"

# Define Groups

group_names=[("  ",{'layout': def_layout, 'spawn':'termite'}),
           ("  ",{'layout': def_layout}),
           ("  ",{'layout': def_layout,'spawn':'firefox'}),
           ("  ",{'layout': def_layout}),
           ("  ",{'layout': def_layout}),
           ("  ",{'layout': def_layout,'spawn':'bitwarden-desktop'}),
           ("  ",{'layout': def_layout, 'spawn': 'obsidian'}),
           ("  ",{'layout': def_layout, 'spawn':['slack', 'telegram-desktop']}),
           ("  ",{'layout': def_layout, 'spawn':'spotify-launcher'})]

groups = [Group(name, **kwargs) for name, kwargs in group_names]

for i, (name, kwargs) in enumerate(group_names, 1):
    keys.append(Key([mod], str(i), lazy.group[name].toscreen()))        # Switch to another group
    keys.append(Key([mod, "shift"], str(i), lazy.window.togroup(name))) # Send current window to another group	

##### DEFAULT THEME SETTINGS FOR LAYOUTS #####
layout_theme = {"border_width": 2,
                "margin": 5,
                "border_focus": colors[7],
                "border_normal": "1D2330"
                }

layouts = [
    layout.Bsp(**layout_theme),
    layout.Max(**layout_theme),
    # layout.Stack(num_stacks=2),
    # Try more layouts by unleashing below layouts.
    # layout.Columns(),
    # layout.Matrix(),
    layout.MonadTall(**layout_theme),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

### COLORS ###

# colors = ["003b4c",     # Background
#         "66a5ad",       # Current group 
#         "ececec",       # Highlight Text
#         "999999",       # Dark Text
#         "73b8bf",       # Widget 1 Color
#         "50a5af",       # Widget 2 Color
#         "40848c",       # Widget 3 Color
#         "306369",       # Widget 4 Color
#         "204246",       # Widget 5 Color
#         "102123",       # Widget 6 Color

#         ]

# Define the foreground (text) color
fgcolor = colors[0]

widget_defaults = dict(
    font='Inconsolata',
    fontsize=15,
    padding=3,
    background = colors[0]
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.Sep(
                    linewidth = 0,
                    padding = 9,
                    ),
                widget.GroupBox(
                    rounded = False,
                    active = colors[7],     # Color of text of active group
                    inactive = colors[6],
                    highlight_method = 'block',
                    highlight_color = [colors[3], colors[4]],
                    # current_screen_border = colors[1],
                    this_current_screen_border = colors[1],
                    ),
                widget.Sep(
                    linewidth = 0,
                    padding = 20,
                    ),
                widget.Spacer(),
                widget.Wlan(
                    background = colors[4],
                    foreground = colors[0],
                    interface = 'wlan0',
                    format = '  {essid} {percent:2.0%} |'
                    ),
                widget.Net(
                    background = colors[4],
                    foreground = fgcolor,
                    format = '{down}  {up} ',
                    disconnected_message = 'N/A',
                    ),
                widget.TextBox(
                    " Layout:",
                    background = colors[5],
                    foreground = fgcolor,
                    ),
                widget.CurrentLayoutIcon(
                    background = colors[5],
                    foreground = fgcolor,
                    scale = 0.7,
                    padding = 8,
                    ),
#                widget.CurrentLayout(
#                    background = colors[5],
#                    foreground = fgcolor,
#                    padding = 5,
#                    ),
                widget.Volume(
                    emoji = False,
                    background = colors[6],
                    foreground = fgcolor,
                    fmt = ' {}',
                    padding = 8,
                    ),
                widget.Clock(
                    format=' %d/%m/%y  %H:%M',
                    background = colors[7],
                    foreground = fgcolor,
                    padding = 9,
                    ),
                widget.Battery(
                    background = colors[8],
                    foreground = fgcolor,
                    format = ' {char} {percent:2.0%} {hour:d}:{min:02d}',
                    padding = 9,
                    ),

            ],
            24,
            margin = [4, 6, 1, 6],
            opacity = 0.85,
        ),
        bottom=bar.Bar(
            [
                widget.Prompt(),
                widget.WindowName(),
                widget.CheckUpdates(
                    distro = 'Arch',
                    fmt = ' - {}',
                    background = colors[5],
                    foreground = fgcolor,
                    padding = 9,
                    no_update_string = ' : N/A'
                    ),
                widget.Pomodoro(
                    background = colors[6],
                    foreground = fgcolor,
                    padding = 9,
                    color_inactive = 'ff9933',
                    ),
                # widget.HDDGraph(
                #     background = colors[7],
                #     foreground = fgcolor,
                #     path = '/dev/sda2',
                #     ),
                widget.Systray(),
            ],
            26,
            margin = [1, 6, 4, 6],
            opacity = 0.85,
        ),
    ),

    Screen(
        top=bar.Bar(
            [
                widget.Sep(
                    linewidth = 0,
                    padding = 9,
                    ),
                widget.GroupBox(
                    rounded = False,
                    active = colors[7],     # Color of text of active group
                    inactive = colors[6],
                    highlight_method = 'block',
                    highlight_color = [colors[3], colors[4]],
                    # current_screen_border = colors[1],
                    this_current_screen_border = colors[1],
                    ),
                widget.Sep(
                    linewidth = 0,
                    padding = 20,
                    ),
                widget.Spacer(),
                widget.Wlan(
                    background = colors[4],
                    foreground = fgcolor,
                    interface = 'wlan0',
                    format = '  {essid} {percent:2.0%} |'
                    ),
                widget.Net(
                    background = colors[4],
                    foreground = fgcolor,
                    format = '{down}  {up} ',
                    disconnected_message = 'N/A',
                    ),
                widget.TextBox(
                    " Layout:",
                    background = colors[5],
                    foreground = fgcolor,
                    ),
                widget.CurrentLayoutIcon(
                    background = colors[5],
                    foreground = fgcolor,
                    scale = 0.7,
                    padding = 8,
                    ),
#                widget.CurrentLayout(
#                    background = colors[5],
#                    foreground = fgcolor,
#                    padding = 5,
#                    ),
                widget.Volume(
                    emoji = False,
                    background = colors[6],
                    foreground = fgcolor,
                    fmt = ' {}',
                    padding = 8,
                    ),
                widget.Clock(
                    format=' %d/%m/%y  %H:%M',
                    background = colors[7],
                    foreground = fgcolor,
                    padding = 9,
                    ),
                widget.Battery(
                    background = colors[8],
                    foreground = fgcolor,
                    format = ' {char} {percent:2.0%} {hour:d}:{min:02d}',
                    padding = 9,
                    ),

            ],
            24,
            margin = [4, 6, 1, 6],
            opacity = 0.85,
        ),
        bottom=bar.Bar(
            [
                widget.Prompt(),
                widget.WindowName(),
                widget.CheckUpdates(
                    distro = 'Arch',
                    fmt = ' - {}',
                    background = colors[5],
                    foreground = fgcolor,
                    padding = 9,
                    no_update_string = ' : N/A' 
                    ),
                widget.Pomodoro(
                    background = colors[6],
                    foreground = fgcolor,
                    padding = 9,
                    color_inactive = 'ff9933',
                    ),
                # widget.HDDGraph(
                #     background = colors[7],
                #     foreground = fgcolor,
                #     path = '/dev/sda2',
                #     ),
                # widget.Systray(),
            ],
            26,
            margin = [1, 6, 4, 6],
            opacity = 0.85,
        ),
    ),

    Screen(
        top=bar.Bar(
            [
                widget.Sep(
                    linewidth = 0,
                    padding = 9,
                    ),
                widget.GroupBox(
                    rounded = False,
                    active = colors[7],     # Color of text of active group
                    inactive = colors[6],
                    highlight_method = 'block',
                    highlight_color = [colors[3], colors[4]],
                    # current_screen_border = colors[1],
                    this_current_screen_border = colors[1],
                    ),
                widget.Sep(
                    linewidth = 0,
                    padding = 20,
                    ),
                widget.Spacer(),
                widget.Wlan(
                    background = colors[4],
                    foreground = colors[0],
                    interface = 'wlan0',
                    format = '  {essid} {percent:2.0%} |'
                    ),
                widget.Net(
                    background = colors[4],
                    foreground = fgcolor,
                    format = '{down}  {up} ',
                    disconnected_message = 'N/A',
                    ),
                widget.TextBox(
                    " Layout:",
                    background = colors[5],
                    foreground = fgcolor,
                    ),
                widget.CurrentLayoutIcon(
                    background = colors[5],
                    foreground = fgcolor,
                    scale = 0.7,
                    padding = 8,
                    ),
#                widget.CurrentLayout(
#                    background = colors[5],
#                    foreground = fgcolor,
#                    padding = 5,
#                    ),
                widget.Volume(
                    emoji = False,
                    background = colors[6],
                    foreground = fgcolor,
                    fmt = ' {}',
                    padding = 8,
                    ),
                widget.Clock(
                    format=' %d/%m/%y  %H:%M',
                    background = colors[7],
                    foreground = fgcolor,
                    padding = 9,
                    ),
                widget.Battery(
                    background = colors[8],
                    foreground = fgcolor,
                    format = ' {char} {percent:2.0%} {hour:d}:{min:02d}',
                    padding = 9,
                    ),

            ],
            24,
            margin = [4, 6, 1, 6],
            opacity = 0.85,
        ),
        bottom=bar.Bar(
            [
                widget.Prompt(),
                widget.WindowName(),
                widget.CheckUpdates(
                    distro = 'Arch',
                    fmt = ' - {}',
                    background = colors[5],
                    foreground = fgcolor,
                    padding = 9,
                    no_update_string = ' : N/A'
                    ),
                widget.Pomodoro(
                    background = colors[6],
                    foreground = fgcolor,
                    padding = 9,
                    color_inactive = 'ff9933',
                    ),
                # widget.HDDGraph(
                #     background = colors[7],
                #     foreground = fgcolor,
                #     path = '/dev/sda2',
                #     ),
                # widget.Systray(),
            ],
            26,
            margin = [1, 6, 4, 6],
            opacity = 0.85,
        ),
    ),
]


# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
#floating_layout = layout.Floating(float_rules=[
#    # Run the utility of `xprop` to see the wm class and name of an X client.
#    *layout.Floating.default_float_rules,
#    Match(title = 'Qalculate!')
#    ]) 
auto_fullscreen = True
focus_on_window_activation = "smart"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

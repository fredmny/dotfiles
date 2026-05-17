-- Hyprland 0.55 lua config
-- Migrated from hyprland.conf (hyprlang 0.54)

--------------------
--- MONITORS ---
--------------------

require("monitors")

---------------------------
--- API COMPATIBILITY ---
---------------------------

local function make_config_proxy(path)
    local proxy = {}

    setmetatable(proxy, {
        __index = function(_, key)
            local child = { table.unpack(path) }
            child[#child + 1] = key
            return make_config_proxy(child)
        end,
        __newindex = function(_, key, value)
            local child = { table.unpack(path) }
            child[#child + 1] = key

            if table.concat(child, ".") == "general.col.active_border" and type(value) == "string" then
                local c1, c2, angle = value:match("^(rgba%b())%s+(rgba%b())%s+(%-?[%d%.]+)deg$")
                if c1 and c2 and angle then
                    value = {
                        colors = { c1, c2 },
                        angle = tonumber(angle),
                    }
                end
            end

            local cfg = value
            for i = #child, 1, -1 do
                cfg = { [child[i]] = cfg }
            end

            hl.config(cfg)
        end,
    })

    return proxy
end

hl.general = hl.general or make_config_proxy({ "general" })
hl.decoration = hl.decoration or make_config_proxy({ "decoration" })
hl.animations = hl.animations or make_config_proxy({ "animations" })
hl.dwindle = hl.dwindle or make_config_proxy({ "dwindle" })
hl.master = hl.master or make_config_proxy({ "master" })
hl.misc = hl.misc or make_config_proxy({ "misc" })
hl.input = hl.input or make_config_proxy({ "input" })

if not hl.bezier and hl.curve then
    hl.bezier = function(opts)
        return hl.curve(opts.name, {
            type = "bezier",
            points = {
                { opts.x0, opts.y0 },
                { opts.x1, opts.y1 },
            },
        })
    end
end

if hl.animation then
    local raw_animation = hl.animation
    hl.animation = function(opts)
        if opts.leaf == nil and opts.name ~= nil then
            opts.leaf = opts.name
            opts.name = nil
        end
        if opts.bezier == nil and opts.curve ~= nil then
            opts.bezier = opts.curve
            opts.curve = nil
        end
        return raw_animation(opts)
    end
end

if hl.gesture then
    local raw_gesture = hl.gesture
    hl.gesture = function(arg)
        if type(arg) == "string" then
            local fingers, direction, action = arg:match("^%s*(%d+)%s*,%s*(%w+)%s*,%s*(%w+)%s*$")
            if fingers and direction and action then
                return raw_gesture({
                    fingers = tonumber(fingers),
                    direction = direction,
                    action = action,
                })
            end
        end

        return raw_gesture(arg)
    end
end

if not hl.submap and hl.define_submap then
    hl.submap = hl.define_submap
end

if hl.dsp then
    if hl.dsp.exec_cmd and not hl.dsp.exec then
        hl.dsp.exec = hl.dsp.exec_cmd
    end
    if hl.dsp.window and hl.dsp.window.close and not hl.dsp.killactive then
        hl.dsp.killactive = hl.dsp.window.close
    end
    if hl.dsp.window and hl.dsp.window.float and not hl.dsp.togglefloating then
        hl.dsp.togglefloating = function()
            return hl.dsp.window.float({ action = "toggle" })
        end
    end
    if hl.dsp.window and hl.dsp.window.pseudo and not hl.dsp.pseudo then
        hl.dsp.pseudo = hl.dsp.window.pseudo
    end
    if hl.dsp.layout and not hl.dsp.layoutmsg then
        hl.dsp.layoutmsg = hl.dsp.layout
    end
    if hl.dsp.focus and not hl.dsp.movefocus then
        hl.dsp.movefocus = function(direction)
            local map = { l = "left", r = "right", u = "up", d = "down" }
            return hl.dsp.focus({ direction = map[direction] or direction })
        end
    end
    if hl.dsp.window and hl.dsp.window.move and not hl.dsp.movetoworkspace then
        hl.dsp.movetoworkspace = function(workspace)
            return hl.dsp.window.move({ workspace = workspace })
        end
    end
    if hl.dsp.workspace and hl.dsp.workspace.toggle_special and not hl.dsp.togglespecialworkspace then
        hl.dsp.togglespecialworkspace = hl.dsp.workspace.toggle_special
    end
    if hl.dsp.focus and type(hl.dsp.workspace) == "table" then
        local workspace_ns = hl.dsp.workspace
        if getmetatable(workspace_ns) == nil then
            setmetatable(workspace_ns, {
                __call = function(_, workspace)
                    return hl.dsp.focus({ workspace = workspace })
                end,
            })
        end
    end
    if hl.dsp.window and hl.dsp.window.drag and not hl.dsp.movewindow then
        hl.dsp.movewindow = function(direction)
            if direction == nil then
                return hl.dsp.window.drag()
            end
            local map = { l = "left", r = "right", u = "up", d = "down" }
            return hl.dsp.window.move({ direction = map[direction] or direction })
        end
    end
    if hl.dsp.window and hl.dsp.window.resize and not hl.dsp.resizewindow then
        hl.dsp.resizewindow = hl.dsp.window.resize
    end
end

--------------------
--- MY PROGRAMS ---
--------------------

local terminal = "ghostty"
local fileManager = "dolphin"
local menu = "rofi -show drun"
local lockScreenManager = "hyprlock"
local browser = "zen-browser"

--------------------
--- PYWAL COLORS ---
--------------------

-- Parse pywal colors from hyprlang format
local colors = {}
local wal_path = os.getenv("HOME") .. "/.cache/wal/colors-hyprland.conf"
local f = io.open(wal_path, "r")
if f then
    for line in f:lines() do
        local key, val = line:match("^%$(%w+)%s*=%s*(.+)$")
        if key and val then
            colors[key] = val
        end
    end
    f:close()
end

--------------------
--- AUTOSTART ---
--------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("mako")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/rotate-wallpaper.sh")
    hl.exec_cmd("waybar & hypridle")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("rm -f $SSH_AUTH_SOCK && ssh-agent -a $SSH_AUTH_SOCK && sleep 1 && ssh-add ~/.ssh/github")
    hl.exec_cmd("[workspace 1] " .. terminal)
    hl.exec_cmd("[workspace 3 silent] " .. browser)
    hl.exec_cmd("[workspace 7 silent] obsidian")
    hl.exec_cmd("[workspace 10 silent] spotify")
    hl.exec_cmd("clipcatd")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/weekend-notify.sh")
end)

-------------------------------
--- ENVIRONMENT VARIABLES ---
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XKB_DEFAULT_LAYOUT", "us")
hl.env("XKB_DEFAULT_VARIANT", "intl")
hl.env("SSH_AUTH_SOCK", "$XDG_RUNTIME_DIR/ssh-agent.socket")

-----------------------
--- LOOK AND FEEL ---
-----------------------

-- General
hl.general.gaps_in = 4
hl.general.gaps_out = 12
hl.general.border_size = 2
hl.general["col.active_border"] = (colors.color3 or "rgba(33ccffee)") .. " " .. (colors.color6 or "rgba(00ff99ee)") .. " 45deg"
hl.general["col.inactive_border"] = "rgba(5e605aff)"
hl.general.resize_on_border = false
hl.general.allow_tearing = false
hl.general.layout = "dwindle"

-- Decoration
hl.decoration.rounding = 3
hl.decoration.rounding_power = 2
hl.decoration.active_opacity = 1.0
hl.decoration.inactive_opacity = 0.9

hl.decoration.shadow.enabled = true
hl.decoration.shadow.range = 4
hl.decoration.shadow.render_power = 3
hl.decoration.shadow.color = "rgba(000000ee)"

hl.decoration.blur.enabled = true
hl.decoration.blur.size = 3
hl.decoration.blur.passes = 1
hl.decoration.blur.vibrancy = 0.1696

-- Animations
hl.animations.enabled = true

hl.bezier({ name = "easeOutQuint",   x0 = 0.23, y0 = 1,    x1 = 0.32, y1 = 1 })
hl.bezier({ name = "easeInOutCubic", x0 = 0.65, y0 = 0.05, x1 = 0.36, y1 = 1 })
hl.bezier({ name = "linear",         x0 = 0,    y0 = 0,    x1 = 1,    y1 = 1 })
hl.bezier({ name = "almostLinear",   x0 = 0.5,  y0 = 0.5,  x1 = 0.75, y1 = 1 })
hl.bezier({ name = "quick",          x0 = 0.15, y0 = 0,    x1 = 0.1,  y1 = 1 })

hl.animation({ name = "global",        enabled = true, speed = 10,   curve = "default" })
hl.animation({ name = "border",        enabled = true, speed = 5.39, curve = "easeOutQuint" })
hl.animation({ name = "windows",       enabled = true, speed = 4.79, curve = "easeOutQuint" })
hl.animation({ name = "windowsIn",     enabled = true, speed = 4.1,  curve = "easeOutQuint", style = "popin 87%" })
hl.animation({ name = "windowsOut",    enabled = true, speed = 1.49, curve = "linear",       style = "popin 87%" })
hl.animation({ name = "fadeIn",        enabled = true, speed = 1.73, curve = "almostLinear" })
hl.animation({ name = "fadeOut",       enabled = true, speed = 1.46, curve = "almostLinear" })
hl.animation({ name = "fade",          enabled = true, speed = 3.03, curve = "quick" })
hl.animation({ name = "layers",        enabled = true, speed = 3.81, curve = "easeOutQuint" })
hl.animation({ name = "layersIn",      enabled = true, speed = 4,    curve = "easeOutQuint", style = "fade" })
hl.animation({ name = "layersOut",     enabled = true, speed = 1.5,  curve = "linear",       style = "fade" })
hl.animation({ name = "fadeLayersIn",  enabled = true, speed = 1.79, curve = "almostLinear" })
hl.animation({ name = "fadeLayersOut", enabled = true, speed = 1.39, curve = "almostLinear" })
hl.animation({ name = "workspaces",    enabled = true, speed = 1.94, curve = "almostLinear", style = "fade" })
hl.animation({ name = "workspacesIn",  enabled = true, speed = 1.21, curve = "almostLinear", style = "fade" })
hl.animation({ name = "workspacesOut", enabled = true, speed = 1.94, curve = "almostLinear", style = "fade" })
hl.animation({ name = "zoomFactor",    enabled = true, speed = 7,    curve = "quick" })

-- Layouts
hl.dwindle.preserve_split = true
hl.master.new_status = "master"

-- Misc
hl.misc.force_default_wallpaper = 0
hl.misc.disable_hyprland_logo = true

---------------
--- INPUT ---
---------------

hl.input.kb_layout = "us"
hl.input.kb_model = ""
hl.input.kb_options = ""
hl.input.kb_rules = ""
hl.input.follow_mouse = 1
hl.input.sensitivity = 0

hl.input.touchpad.natural_scroll = false

-- Gestures
hl.gesture("3, horizontal, workspace")

-- Per-device config
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
--- KEYBINDINGS ---
---------------------

local mainMod = "SUPER"

-- Core binds
hl.bind(mainMod .. " + return",       hl.dsp.exec(terminal))
hl.bind(mainMod .. " + C",            hl.dsp.killactive())
hl.bind(mainMod .. " + Q",            hl.dsp.killactive())
hl.bind(mainMod .. " + M",            hl.dsp.exit())
hl.bind(mainMod .. " + E",            hl.dsp.exec(fileManager))
hl.bind(mainMod .. " + V",            hl.dsp.togglefloating())
hl.bind(mainMod .. " + R",            hl.dsp.exec(menu))
hl.bind(mainMod .. " + space",        hl.dsp.exec(menu))
hl.bind(mainMod .. " + P",            hl.dsp.pseudo())
hl.bind(mainMod .. " + TAB",          hl.dsp.layoutmsg("togglesplit"))
hl.bind("SUPER + CTRL + Q",           hl.dsp.exec(lockScreenManager))

-- Rofi submap
local function exec_from_rofi_submap(cmd)
    return function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.exec_cmd(cmd)
    end
end

hl.submap("rofi_submenu", function()
    hl.bind("F", exec_from_rofi_submap("rofi -show filebrowser"))
    hl.bind("E", exec_from_rofi_submap("rofi -modi emoji -show emoji"))
    hl.bind("C", exec_from_rofi_submap("clipcat-menu"))
    hl.bind("S", exec_from_rofi_submap("rofi -show ssh"))
    hl.bind("P", exec_from_rofi_submap("~/.config/rofi/scripts/rofi-power.sh"))
    hl.bind("M", exec_from_rofi_submap("~/.config/rofi/scripts/rofi-hypr-move-workspace.sh"))
    hl.bind("L", exec_from_rofi_submap("~/.config/rofi/scripts/rofi-hypr-screen-layout.sh"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind("ALT + space", hl.dsp.submap("rofi_submenu"))

-- Scripts
hl.bind(mainMod .. " + I", hl.dsp.exec(os.getenv("HOME") .. "/.config/hypr/scripts/toggle-kb-variant.sh"))

-- Move focus with arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.movefocus("l"))
hl.bind(mainMod .. " + right", hl.dsp.movefocus("r"))
hl.bind(mainMod .. " + up",    hl.dsp.movefocus("u"))
hl.bind(mainMod .. " + down",  hl.dsp.movefocus("d"))

-- Move focus with vim keys
hl.bind(mainMod .. " + H", hl.dsp.movefocus("l"))
hl.bind(mainMod .. " + L", hl.dsp.movefocus("r"))
hl.bind(mainMod .. " + K", hl.dsp.movefocus("u"))
hl.bind(mainMod .. " + J", hl.dsp.movefocus("d"))

-- Move window
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.movewindow("l"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.movewindow("r"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.movewindow("u"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.movewindow("d"))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.workspace(tostring(i)))
end
hl.bind(mainMod .. " + 0", hl.dsp.workspace("10"))

-- Move active window to workspace with mainMod + SHIFT + [0-9]
for i = 1, 9 do
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.movetoworkspace(tostring(i)))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.movetoworkspace("10"))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.togglespecialworkspace("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.movetoworkspace("special:magic"))

-- Scroll through workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.workspace("e+1"))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.workspace("e-1"))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.movewindow(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.resizewindow(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
local media_flags = { repeating = true, locked = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media_flags)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      media_flags)
hl.bind("XF86AudioMute",         hl.dsp.exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     media_flags)
hl.bind("XF86AudioMicMute",      hl.dsp.exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   media_flags)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec("brightnessctl -e4 -n2 set 5%+"),                  media_flags)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec("brightnessctl -e4 -n2 set 5%-"),                  media_flags)

-- Playerctl (locked only, no repeat)
local locked_flags = { locked = true }
hl.bind("XF86AudioNext",  hl.dsp.exec("playerctl next"),       locked_flags)
hl.bind("XF86AudioPause", hl.dsp.exec("playerctl play-pause"), locked_flags)
hl.bind("XF86AudioPlay",  hl.dsp.exec("playerctl play-pause"), locked_flags)
hl.bind("XF86AudioPrev",  hl.dsp.exec("playerctl previous"),   locked_flags)

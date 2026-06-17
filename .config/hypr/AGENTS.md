# Hyprland Config

## Lua API

Hyprland uses the **Lua API** for configuration (since 0.55). All config
changes must use the Lua-based `hl.*` API, not the old hyprlang syntax.

Use `hyprctl eval "..."` to execute Lua code at runtime. The old `hyprctl
keyword` does not work with the Lua config parser.

## Documentation

- Official Wiki (Lua config): https://wiki.hypr.land/Configuring/

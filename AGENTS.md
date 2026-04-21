# Dotfiles

Personal dotfiles used across Linux (Hyprland/Qtile) and macOS. Configs are
symlinked or managed with stow into `$HOME`.

## Repo Structure

```
.zshrc / .zshrc_homelab   # ZSH config (oh-my-zsh + powerlevel10k + zsh-vi-mode)
.tmux.conf                # tmux (prefix: C-Space, homelab: C-b)
.aliases                  # Shell aliases (sourced by .zshrc)
.vimrc                    # Legacy vim config
.scripts/                 # Helper shell scripts
.config/
  hypr/                   # Hyprland — split into hyprland.conf, monitors.conf,
                          #   workspaces.conf, hypridle/lock/paper confs, scripts/
  nvim/                   # Neovim (see below)
  qtile/config.py         # Qtile window manager
  ghostty/                # Terminal emulator
  rofi/                   # App launcher & menus
  waybar/                 # Status bar (Hyprland)
  qutebrowser/config.py   # Qutebrowser
  ranger/rc.conf          # Ranger file manager
  lazygit/                # Lazygit config
  sesh/                   # Session manager for tmux
  macro-keyboard/         # USB macro keyboard mapping
  clipcat/                # Clipboard manager
  gh-dash/                # GitHub dashboard (gh dash)
```

### Neovim

Plugin manager: **lazy.nvim** (`lua/plugins/lazy.lua`).
Each plugin has its own config file in `lua/plugins/config/` (~33 files).

```
.config/nvim/
  init.lua                     # Entry point
  lua/core/
    settings.lua               # Editor options
    keymaps.lua                # Core keybindings + LSP + GitSigns
    theme.lua                  # Colorscheme
  lua/plugins/
    lazy.lua                   # Plugin manager bootstrap
    config/*.lua               # One file per plugin (telescope, harpoon, oil, etc.)
```

## Conventions

- **Dual-platform:** `.zshrc` branches on `uname` for Darwin vs Linux paths.
- **Neovim leader:** `<Space>`.
- **Terminal:** ghostty on both platforms.
- **AI plugins:** CopilotChat and CodeCompanion are both configured; keybindings
  use `<leader>z*` for Copilot and `<leader>c*` for CodeCompanion.

## Keybindings Reference — MANDATORY RULE

`KEYBINDINGS.md` in the repo root is the canonical reference for all keybindings.

**Whenever you modify a keybinding in any of the following files, you MUST update
the corresponding section in `KEYBINDINGS.md` before finishing:**

| Config file | KEYBINDINGS.md section |
|---|---|
| `.config/hypr/hyprland.conf` | Hyprland |
| `.tmux.conf` | tmux |
| `.config/nvim/lua/core/keymaps.lua` | Neovim › Core |
| `.config/nvim/lua/plugins/config/*.lua` | Neovim › relevant plugin section |
| `.config/qtile/config.py` | Qtile |
| `.config/qutebrowser/config.py` | Qutebrowser |
| `.config/ranger/rc.conf` | Ranger |
| `.zshrc` | ZSH |
| `.config/macro-keyboard/mapping.yaml` | Macro Keyboard |

**Update strategy:** surgical edit — only change the rows or sections directly
affected. Do not regenerate the entire file.

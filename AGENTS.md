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

## KDE Connect (Hyprland)

`arch_configure.sh` installs `kdeconnect`, `sshfs`, `hypr-kdeconnect-fix-git`
(AUR), and opens UFW ports `1714:1764` UDP/TCP. This gets devices paired and
file browsing working, but **incoming file transfers require an extra manual
step** that the script does not automate.

### Why manual config is needed

By default, KDE Connect shows a notification with Accept/Decline buttons when
a file is incoming. On Plasma this works natively, but on Hyprland the action
callbacks are not wired up (even with mako's `actions=1`), so transfers hang
silently waiting for an acceptance that never happens.

### Per-device share config (run once after pairing each device)

For each paired device, create a share plugin config at
`~/.config/kdeconnect/<device_id>/kdeconnect_share/config` with an
`incomingPath` so files auto-accept and save directly:

```ini
[General]
incomingPath=/home/prophet/Downloads/kdeconnect/<DeviceName>
```

- `<device_id>` is the 32-char hex directory under `~/.config/kdeconnect/`
  (find it with `ls ~/.config/kdeconnect/`).
- Create the destination subfolder under `~/Downloads/kdeconnect/` first.
- Restart `kdeconnectd` if it's already running so the config is re-read.
- The `kcd` shell function (in `.aliases`) `cd`s into the active device's
  sshfs mount under `/run/user/$(id -u)/<device_id>` for terminal file access.

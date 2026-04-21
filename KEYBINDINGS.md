# Keybindings Reference

> Auto-generated from dotfiles. All keybindings organized by tool.

---

## Table of Contents

- [Hyprland](#hyprland)
- [tmux](#tmux)
- [Neovim](#neovim)
- [Qtile](#qtile)
- [Qutebrowser](#qutebrowser)
- [Ranger](#ranger)
- [ZSH](#zsh)
- [Macro Keyboard](#macro-keyboard)

---

## Hyprland

**Config:** `.config/hypr/hyprland.conf`  
**Modifier:** `$mainMod = SUPER`

### Window Management

| Keybind | Action |
|---|---|
| `SUPER + Return` | Launch terminal (ghostty) |
| `SUPER + C` | Kill active window |
| `SUPER + Q` | Kill active window |
| `SUPER + M` | Exit Hyprland |
| `SUPER + E` | Open file manager (dolphin) |
| `SUPER + V` | Toggle floating |
| `SUPER + R` | Open app launcher (rofi drun) |
| `SUPER + Space` | Open app launcher (rofi drun) |
| `SUPER + P` | Pseudo-tile (dwindle) |
| `SUPER + TAB` | Toggle split (dwindle) |
| `SUPER + CTRL + Q` | Lock screen (hyprlock) |
| `SUPER + I` | Toggle keyboard layout variant |
| `SUPER + S` | Toggle special workspace (scratchpad) |
| `SUPER + SHIFT + S` | Move window to special workspace |

### Focus Movement

| Keybind | Action |
|---|---|
| `SUPER + Left` / `SUPER + H` | Move focus left |
| `SUPER + Right` / `SUPER + L` | Move focus right |
| `SUPER + Up` / `SUPER + K` | Move focus up |
| `SUPER + Down` / `SUPER + J` | Move focus down |

### Window Movement

| Keybind | Action |
|---|---|
| `SUPER + SHIFT + H` | Move window left |
| `SUPER + SHIFT + L` | Move window right |
| `SUPER + SHIFT + K` | Move window up |
| `SUPER + SHIFT + J` | Move window down |

### Workspaces

| Keybind | Action |
|---|---|
| `SUPER + 1–9` | Switch to workspace 1–9 |
| `SUPER + 0` | Switch to workspace 10 |
| `SUPER + SHIFT + 1–9` | Move active window to workspace 1–9 |
| `SUPER + SHIFT + 0` | Move active window to workspace 10 |
| `SUPER + scroll down` | Next workspace |
| `SUPER + scroll up` | Previous workspace |

### Mouse

| Keybind | Action |
|---|---|
| `SUPER + LMB drag` | Move window |
| `SUPER + RMB drag` | Resize window |

### Media / System Keys

| Keybind | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioLowerVolume` | Volume -5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Brightness +5% |
| `XF86MonBrightnessDown` | Brightness -5% |
| `XF86AudioNext` | playerctl next |
| `XF86AudioPause` | playerctl play-pause |
| `XF86AudioPlay` | playerctl play-pause |
| `XF86AudioPrev` | playerctl previous |

### Rofi Submap

> Enter with `ALT + Space`, then press a single key. Press `Escape` to cancel.

| Key | Action |
|---|---|
| `F` | rofi filebrowser |
| `E` | rofi emoji picker |
| `C` | clipcat-menu (clipboard manager) |
| `S` | rofi ssh |
| `P` | rofi power menu |
| `M` | rofi hypr move workspace |
| `L` | rofi hypr screen layout |

---

## tmux

**Config:** `.tmux.conf`  
**Prefix:** `C-Space` (personal) / `C-b` (homelab)

| Keybind | Action |
|---|---|
| `prefix + r` | Reload tmux config |
| `prefix + h` | Select pane left |
| `prefix + j` | Select pane down |
| `prefix + k` | Select pane up |
| `prefix + l` | Select pane right |
| `prefix + C-f` | Fuzzy session switcher (sesh + fzf-tmux) |
| `prefix + N` | Prompt for new session name and create it |
| `prefix + X` | Kill current session, switch to previous |
| `prefix + C-n` | New session in current directory |
| `prefix + L` | Switch to last session (via sesh) |
| `prefix + c` | New window in current directory |
| `prefix + "` | Horizontal split in current directory |
| `prefix + %` | Vertical split in current directory |
| `prefix + g` | Popup: GitHub Dashboard (gh dash) |
| `prefix + t` | Popup: zsh shell |
| `prefix + n` | Popup: Obsidian inbox note in `$EDITOR` |
| `prefix + d` | Popup: Lazydocker |
| `prefix + f` | Popup: Ranger file manager |
| `M-s` | Choose session (no prefix) |
| `M-f` | Fuzzy session switcher (no prefix) |

### sesh fzf-tmux Inner Bindings

> Active inside the fuzzy session picker.

| Key | Action |
|---|---|
| `Tab` / `Shift-Tab` | Down / Up |
| `Ctrl-A` | Show all sessions |
| `Ctrl-T` | Show tmux sessions only |
| `Ctrl-G` | Show config sessions |
| `Ctrl-X` | Show zoxide directories |
| `Ctrl-F` | Find directories with `fd` |
| `Ctrl-D` | Kill highlighted tmux session |

---

## Neovim

**Config:** `.config/nvim/`  
**Leader:** `<Space>`

### Core

**File:** `lua/core/keymaps.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<leader>h` | n | Clear search highlights |
| `<leader>w` | n | Save file |
| `<leader>qq` | n | Quit |
| `<leader>qw` | n | Save and quit |
| `qn` | n | Next quickfix item |
| `qp` | n | Previous quickfix item |
| `<leader>j` | n | Next buffer |
| `<leader>k` | n | Previous buffer |
| `<C-d>` | n | Scroll down and center |
| `<C-u>` | n | Scroll up and center |
| `<leader>bo` | n | Delete all buffers except current |
| `<leader>-` | n | Toggle Twilight |
| `<leader>bt` | n | Open current buffer in new tab |

### LSP

| Keybind | Mode | Action |
|---|---|---|
| `gD` | n | Go to declaration |
| `gd` | n | Go to definition |
| `K` | n | Show hover documentation |
| `gi` | n | Go to implementation |
| `<leader>e` | n | Show diagnostics float |
| `<leader>D` | n | Go to type definition |
| `<leader>rn` | n | Rename symbol |
| `gr` | n | Show references |
| `<leader>f` | n | Format file (async) |

### GitSigns

| Keybind | Mode | Action |
|---|---|---|
| `<leader>gb` | n | Git blame line |
| `<leader>gj` | n | Next git hunk |
| `<leader>gk` | n | Previous git hunk |
| `<leader>gp` | n | Preview git hunk |
| `<leader>gtb` | n | Toggle inline git blame |

### Telescope

**File:** `lua/plugins/config/telescope.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<C-p>` | n | Find files |
| `<Space><Space>` | n | Recent files |
| `<Space>tg` | n | Live grep |
| `<Space>th` | n | Help tags |
| `<Space>tb` | n | Buffers |
| `<Space>td` | n | DBT picker (dbtpal) |

### Harpoon

**File:** `lua/plugins/config/harpoon.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<Space>pa` | n | Add file to harpoon list |
| `<Space>pp` | n | Toggle harpoon quick menu |
| `<Space>pj` | n | Next harpoon file |
| `<Space>pk` | n | Previous harpoon file |
| `<Space>pq` | n | Select harpoon file 1 |
| `<Space>pw` | n | Select harpoon file 2 |
| `<Space>pe` | n | Select harpoon file 3 |
| `<Space>pr` | n | Select harpoon file 4 |

### File Navigation

**nvim-tree** (`lua/plugins/config/nvim-tree.lua`)

| Keybind | Mode | Action |
|---|---|---|
| `<C-n>` | n | Toggle file tree |

**Oil** (`lua/plugins/config/oil.lua`)

| Keybind | Mode | Action |
|---|---|---|
| `-` | n | Open parent directory in Oil |
| `g?` | n | Show Oil help |
| `<CR>` | — | Select / open |
| `<C-s>` | — | Open in vertical split |
| `<C-h>` | — | Open in horizontal split |
| `<C-t>` | — | Open in new tab |
| `<C-e>` | — | Preview |
| `<C-c>` | n | Close |
| `<C-l>` | — | Refresh |
| `_` | n | Open cwd |
| `` ` `` | n | cd to directory |
| `~` | n | cd to directory (tab scope) |
| `gs` | n | Change sort |
| `gx` | — | Open external |
| `g.` | n | Toggle hidden files |
| `g\` | n | Toggle trash |

### Undotree

**File:** `lua/plugins/config/undotree.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<leader>u` | n | Toggle Undotree |

### UFO (Folding)

**File:** `lua/plugins/config/ufo.lua`

| Keybind | Mode | Action |
|---|---|---|
| `zR` | n | Open all folds |
| `zM` | n | Close all folds |
| `zK` | n | Peek folded lines under cursor |

### Lspsaga

**File:** `lua/plugins/config/lspsaga.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<leader>lo` | n | Open outline |
| `<leader>ca` | n/v | Run code action |
| `<leader>lr` | n/v | Rename (replace in project) |
| `<leader>lj` | n/v | Jump to next diagnostic |
| `<leader>lk` | n/v | Jump to previous diagnostic |
| `<leader>ld` | n/v | Peek definition |
| `<leader>lt` | n/v | Peek type definition |
| `<leader>lf` | n/v | Open Lspsaga finder |
| `<leader>lm` | n/v | Open hover docs |

### DAP (Debugger)

**File:** `lua/plugins/config/dap.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<leader>db` | n | Toggle breakpoint |
| `<leader>dC` | n | Clear breakpoints |
| `<leader>dc` | n | Continue |
| `<leader>dl` | n | Open REPL |
| `<leader>dr` | n | Restart |
| `<leader>dt` | n | Terminate |
| `<leader>dI` | n | Step into |
| `<leader>dO` | n | Step out |
| `<leader>do` | n | Step over |
| `<leader>du` | n | Toggle DAP UI |

### Completions (nvim-cmp + LuaSnip)

**File:** `lua/plugins/config/completions.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<C-b>` | insert | Scroll docs up |
| `<C-f>` | insert | Scroll docs down |
| `<C-Space>` | insert | Trigger completion |
| `<C-e>` | insert | Abort completion |
| `<CR>` | insert | Confirm completion (explicit) |
| `<C-K>` | insert | Confirm completion (select first) |
| `<C-S>` | insert | Expand snippet |
| `<C-L>` | insert/select | Jump to next snippet position |
| `<C-J>` | insert/select | Jump to previous snippet position |
| `<C-E>` | insert/select | Change snippet choice |

### Copilot / CopilotChat

**File:** `lua/plugins/config/copilot.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<C-l>` | insert | Accept Copilot suggestion |
| `<C-c>` | n/insert | Reset/close CopilotChat |
| `q` | n | Close CopilotChat |
| `<leader>cT` | n | Toggle Copilot auto-trigger |
| `<leader>zz` | n/v | Open CopilotChat |
| `<leader>ze` | v | Explain |
| `<leader>zr` | v | Review |
| `<leader>zf` | v | Fix |
| `<leader>zo` | v | Optimize |
| `<leader>zd` | v | Generate docs |
| `<leader>zt` | v | Generate tests |
| `<leader>zc` | n | Write commit message |
| `<leader>zM` | n | Select chat model |
| `<leader>zA` | n | Select chat agent |

### CodeCompanion

**File:** `lua/plugins/config/codecompanion.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<leader>cc` | n/v | Open CodeCompanion Chat |
| `<leader>ct` | n/v | Toggle CodeCompanion Chat |
| `<leader>cz` | n/v | CodeCompanion Actions |
| `<leader>ci` | n/v | CodeCompanion Inline |
| `<leader>ce` | v | Explain |
| `<leader>cf` | v | Fix |
| `<leader>cl` | v | Explain LSP diagnostics |
| `<leader>cpt` | v | Generate tests |
| `<leader>cm` | n | Write commit message |
| `<leader>cpr` | n | Review code |
| `<leader>cpp` | n | Create PR description |
| `<leader>cb` | n/v | Chat with current buffer |

### Snacks (Lazygit + Notifications + Zen)

**File:** `lua/plugins/config/snacks.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<leader>gl` | n | Lazygit log |
| `<leader>nu` | n | Dismiss all notifications |
| `<leader>nh` | n | Show notification history |
| `<leader>gg` | n | Open Lazygit |
| `<leader>Z` | n | Toggle zoom (zen) |
| `<leader>gB` | n/v | Git browse (open in browser) |

### Obsidian

**File:** `lua/plugins/config/obsidian.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<leader>oo` | n | Open note in Obsidian app |
| `<leader>ob` | n | Show backlinks |
| `<leader>oi` | n | Paste clipboard image into note |
| `<leader>oc` | n | Toggle checkbox |
| `<leader>of` | n | Follow Obsidian link |

### Octo (GitHub in Neovim)

**File:** `lua/plugins/config/octo.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<leader>O` | n/v | Open Octo |
| `<C-b>` | — | Open issue/PR in browser |
| `<C-y>` | — | Copy URL to clipboard |
| `<C-o>` | — | Checkout pull request |
| `<C-r>` | — | Merge PR / refresh / request changes |
| `<C-f>` | — | Rerun failed workflow |
| `<C-x>` | — | Cancel workflow |
| `<C-c>` | n/i | Close review tab |
| `<C-a>` | n/i | Approve review |
| `<C-m>` | n/i | Comment review |

### Git Worktree

**File:** `lua/plugins/config/git-worktree.lua`

| Keybind | Mode | Action |
|---|---|---|
| `<Space>twl` | n | List git worktrees |
| `<Space>twc` | n | Create git worktree |

---

## Qtile

**Config:** `.config/qtile/config.py`  
**Modifier:** `mod = "mod1"` (Alt key)

### Window Management

| Keybind | Action |
|---|---|
| `Alt + Return` | Launch terminal (ghostty) |
| `Alt + W` | Kill window |
| `Alt + F` | Toggle floating |
| `Alt + O` | Maximize window |
| `Alt + Tab` | Next layout |
| `Alt + R` | Spawn command prompt |
| `Alt + CTRL + R` | Restart Qtile |
| `Alt + CTRL + Q` | Shutdown Qtile |
| `SUPER + Space` | Launch rofi (drun) |
| `Alt + V` | Launch VS Code |
| `Alt + Q` | Launch qutebrowser |
| `Alt + P` | Position floating window (video player spot) |

### Focus & Movement

| Keybind | Action |
|---|---|
| `Alt + H` | Focus left |
| `Alt + J` | Focus down |
| `Alt + K` | Focus up |
| `Alt + L` | Focus right |
| `Alt + SHIFT + H` | Shuffle window left |
| `Alt + SHIFT + J` | Shuffle window down |
| `Alt + SHIFT + K` | Shuffle window up |
| `Alt + SHIFT + L` | Shuffle window right |
| `Alt + SUPER + H` | Flip layout left |
| `Alt + SUPER + J` | Flip layout down |
| `Alt + SUPER + K` | Flip layout up |
| `Alt + SUPER + L` | Flip layout right |
| `Alt + CTRL + H` | Grow window left |
| `Alt + CTRL + J` | Grow window down |
| `Alt + CTRL + K` | Grow window up |
| `Alt + CTRL + L` | Grow window right |
| `Alt + SHIFT + N` | Normalize layout |
| `Alt + SHIFT + Space` | Rotate stack layout |
| `Alt + SHIFT + Return` | Toggle split layout |

### Screens & Groups

| Keybind | Action |
|---|---|
| `Alt + Y` | Switch to screen 0 |
| `Alt + I` | Switch to screen 1 |
| `Alt + U` | Switch to screen 2 |
| `Alt + 1–9` | Switch to group 1–9 |
| `Alt + SHIFT + 1–9` | Send window to group 1–9 |

### Media / System Keys

| Keybind | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume +2dB |
| `XF86AudioLowerVolume` | Volume -2dB |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioPlay` | Play/pause (spt) |
| `XF86AudioPrev` | Previous track (spt) |
| `XF86AudioNext` | Next track (spt) |
| `XF86MonBrightnessUp` | Brightness +10% |
| `XF86MonBrightnessDown` | Brightness -10% |

### KeyChord: `Alt + Space`, then:

| Key | Action |
|---|---|
| `F` | rofi-fontawesome icon picker |
| `E` | Emoji selector (rofi) |
| `C` | Calculator (rofi-calc) |

### Mouse

| Binding | Action |
|---|---|
| `Alt + LMB drag` | Move floating window |
| `Alt + RMB drag` | Resize floating window |
| `Alt + MMB click` | Bring window to front |

---

## Qutebrowser

**Config:** `.config/qutebrowser/config.py`

| Keybind | Mode | Action |
|---|---|---|
| `M` | normal | Hint links and open in mpv |
| `Z` | normal | Hint links and download with youtube-dl |
| `t` | normal | Open URL in new tab |
| `xb` | normal | Toggle statusbar visibility |
| `xt` | normal | Toggle tab bar visibility |
| `xx` | normal | Toggle statusbar and tab bar |

---

## Ranger

**Config:** `.config/ranger/rc.conf`

| Keybind | Action |
|---|---|
| `bw` | Set selected image as wallpaper (wal), copy to wallpaper folder, restart Qtile |
| `bl` | Set betterlockscreen wallpaper from current wallpaper |

---

## ZSH

**Config:** `.zshrc`

| Keybind | Action |
|---|---|
| `Ctrl + Space` | Accept zsh-autosuggestion |
| `Ctrl + O` | Copy current command line to clipboard (copybuffer) |
| `Ctrl + T` | fzf file search (paste to command line) |
| `Ctrl + R` | fzf history search |
| `Alt + C` | fzf cd into directory |

> ZSH uses `zsh-vi-mode` — full vi keybindings are available in the shell.

---

## Macro Keyboard

**Config:** `.config/macro-keyboard/mapping.yaml`  
**Hardware:** 1 row × 3 buttons + 1 knob, 3 layers

### Layer 1 — Buttons

| Button | Binding | Action |
|---|---|---|
| Button 1 | `Cmd + Shift + J` | — |
| Button 2 | `Cmd + Shift + U` → `Enter` | — |
| Button 3 | `Cmd + E` | — |

### Layer 1 — Knob

| Action | Binding |
|---|---|
| Rotate counter-clockwise | Volume down |
| Press | Mute |
| Rotate clockwise | Volume up |

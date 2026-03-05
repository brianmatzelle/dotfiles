# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for configuring development environments across multiple platforms and desktop environments. All configs are symlinked from this repo into their system locations, so edits here immediately affect the running system.

## Installation

```bash
./install                          # Auto-detects OS, runs the right script
```

The `install` script dispatches to platform-specific installers:
- `_install/arch.sh` — Arch Linux with i3wm (X11)
- `_install/hyprland.sh` — Arch Linux with Hyprland (Wayland)
- `_install/mac.sh` — macOS (cross-platform tools only)
- `_install/debian-server.sh` — Debian headless server

Each installer handles package installation, symlink creation, and neovim config cloning.

## Architecture

### Two Desktop Environments (Arch Linux)

The repo supports two parallel desktop setups on Arch:

1. **i3wm (X11)**: `i3/config` + `polybar/` + `picom/picom.conf` — installed via `_install/arch.sh`
2. **Hyprland (Wayland)**: `hyprland/hyprland.conf` + `waybar/` — installed via `_install/hyprland.sh`

Both use `rofi/` for app launching (rofi-wayland variant for Hyprland) and `ghostty/` as terminal.

### Symlink Strategy

Installers symlink entire directories into `~/.config/`:
- `i3/` -> `~/.config/i3/`
- `hyprland/` -> `~/.config/hypr/` (note: directory name differs)
- `polybar/` -> `~/.config/polybar/`
- `waybar/` -> `~/.config/waybar/`
- `rofi/` -> `~/.config/rofi/`
- `ghostty/` -> `~/.config/ghostty/`
- `gtk-3.0/`, `gtk-4.0/` -> `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/`

Tmux configs are symlinked as `~/.tmux.conf` (work config on macOS, server config on Debian).

### Ghostty Config Generation

`ghostty/config` is generated from `ghostty/config.template` by `ghostty/generate-config.sh`. The template uses `{{WINDOW_DECORATION}}` and `{{GTK_TITLEBAR}}` placeholders replaced with OS-specific values. Don't edit `ghostty/config` directly — edit the template instead.

### Tmux Profiles

Three tmux configurations with different styles:
- `tmux/universal.conf` — base config (no styling, shared keybindings)
- `tmux/work.tmux.conf` — Catppuccin Frappe theme, prefix remapped to `C-a`
- `tmux/server.tmux.conf` — red/yellow theme for servers (default `C-b` prefix)

Style files in `tmux/styles/` correspond to each profile.

### Polybar Scripts

`polybar/` contains helper scripts for custom modules:
- `brightness_check.sh`, `brightness_menu.sh` — brightness control via `brightnessctl`/`ddcutil`
- `wifi_ip.sh` — network IP display
- `launch.sh` — polybar launch script

### Waybar Scripts

`waybar/scripts/` contains:
- `brightness.sh` — brightness control for Hyprland
- `network_ips.sh` — shows all network IPs

### Shell Configuration

- `bash/home.bashrc` — bash config
- `zsh/work.zshrc`, `zsh/work.zsh_functions` — zsh config and functions
- `zsh/universal_aliases.sh` — cross-platform aliases (sourced on Debian servers)

## Key Conventions

- All install scripts use `set -e` and resolve `DOTFILES_DIR` relative to the script location
- Package lists are defined as bash arrays (`PACMAN_REQUIRED_PACKAGES`, `AUR_REQUIRED_PACKAGES`, `BREW_REQUIRED_PACKAGES`) at the top of each installer
- The `create_symlink` helper function handles safe symlink creation (removes existing target first)
- Neovim config is not in this repo — it's cloned separately from `brianmatzelle/kickstart.nvim`
- `hmap_dotfiles.json` and `hmap_dotfiles_detailed.json` are hierarchical memory map exports (gitignored pattern `hmap*`)

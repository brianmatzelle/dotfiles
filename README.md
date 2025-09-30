# dotfiles

My personal configuration files for Arch Linux and macOS.

## 🎯 Overview

This repository contains my dotfiles and automated setup scripts for quickly configuring a new system with my preferred development environment and tools.

**Platform Support:**
- **Arch Linux**: Full support with i3wm, polybar, rofi, and complete desktop environment
- **macOS**: Limited support with cross-platform tools (tmux, neovim, ghostty, CLI utilities)

## 📦 What's Included

### Cross-Platform Configs
- **Neovim**: Custom configuration based on [kickstart.nvim](https://github.com/brianmatzelle/kickstart.nvim)
- **Tmux**: Terminal multiplexer with custom styles for work and server environments
- **Ghostty**: Modern terminal emulator (with OS-specific settings)
- **Zsh/Bash**: Shell configurations, aliases, and functions
- **CLI Tools**: ripgrep, fzf, bat, fd, zoxide, btop, jq

### Arch Linux Only
- **i3wm**: Tiling window manager configuration
- **Polybar**: Custom status bar with brightness, wifi, and system info
- **Rofi**: Application launcher with custom theme
- **Picom**: Compositor for transparency and effects
- **VNC Server**: Setup scripts for remote desktop access

### Fun Extras
- **Wallpapers**: Custom wallpapers (cowboy, wizard)
- **ASCII Art**: cmatrix, pipes.sh, asciiquarium

## 🚀 Quick Start

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Run the installer:**
   ```bash
   ./install.sh
   ```

   The installer automatically detects your OS and runs the appropriate setup script:
   - **macOS** → `_install/mac.sh`
   - **Arch Linux** → `_install/arch.sh`

### What the Installer Does

#### Arch Linux (`_install/arch.sh`)
- Installs packages via `pacman` and `yay` (AUR)
- Creates symlinks for i3, polybar, rofi, picom, ghostty configs
- Clones neovim configuration
- Sets up directory structure for screenshots

**Packages installed:**
- **Window Manager**: i3-wm, polybar, rofi, picom, nitrogen, dunst
- **Development**: neovim, git, tmux, ghostty
- **File Management**: yazi (with ffmpeg, 7zip, jq, fd, bat, fzf, zoxide)
- **System**: brightnessctl, scrot, ddcutil, xss-lock, i3lock
- **Apps**: spotify-launcher, discord, chromium, cursor, postman, docker-desktop
- **Fun**: cmatrix, pipes.sh

#### macOS (`_install/mac.sh`)
- Installs Homebrew (if not present)
- Installs cross-platform packages via `brew`
- Creates symlinks for ghostty, tmux configs (macOS-compatible only)
- Clones neovim configuration
- Generates OS-specific ghostty config with macOS window decorations

**Packages installed:**
- **Core**: git, neovim, tmux, ghostty
- **CLI Tools**: ripgrep, fzf, bat, fd, zoxide, jq
- **Monitoring**: btop
- **Fun**: cmatrix, pipes-sh, asciiquarium

## 📁 Repository Structure

```
dotfiles/
├── _install/          # OS-specific installation scripts
│   ├── arch.sh        # Arch Linux setup
│   └── mac.sh         # macOS setup
├── bash/              # Bash configurations
├── ghostty/           # Ghostty terminal config
├── i3/                # i3 window manager config (Arch only)
├── picom/             # Picom compositor config (Arch only)
├── polybar/           # Polybar status bar (Arch only)
├── rofi/              # Rofi launcher config (Arch only)
├── tmux/              # Tmux configurations and styles
├── zsh/               # Zsh configurations and aliases
├── wallpapers/        # Desktop wallpapers
├── pkg/               # Special package setups (VNC, etc.)
├── setup/             # Additional setup scripts
└── install.sh         # Main installation script
```

## 🛠️ Manual Configuration

### Tmux
The repository includes multiple tmux configurations:
- `tmux/universal.conf` - Base configuration
- `tmux/work.tmux.conf` - Work environment setup
- `tmux/server.tmux.conf` - Server environment setup

### Zsh Functions and Aliases
Check out `zsh/work.zsh_functions` and `zsh/work.zsh_aliases` for productivity shortcuts.

### VNC Server (Arch Linux)
For remote desktop setup, see `pkg/vnc/` directory with setup scripts and systemd service files.

## 🎨 Customization

Feel free to fork and modify these configs for your own use! Key areas to customize:

1. **Package Lists**: Edit `_install/arch.sh` or `_install/mac.sh` to add/remove packages
2. **i3 Keybindings**: Modify `i3/config`
3. **Polybar Modules**: Customize `polybar/config.ini`
4. **Terminal Colors**: Edit `ghostty/config` or `ghostty/config.template`
5. **Shell Aliases**: Add your own to `zsh/work.zsh_aliases`

## 📝 Notes

- **Backup First**: The installer will overwrite existing configs, so backup anything important
- **Symlinks**: All configs use symlinks, so changes to files in this repo immediately affect your system
- **Neovim**: The installer clones a separate neovim config repo - see [kickstart.nvim](https://github.com/brianmatzelle/kickstart.nvim)
- **Arch Linux**: Requires `yay` AUR helper for full package installation
- **macOS**: Window manager configs (i3, polybar, etc.) are not installed since they're Linux-specific

## 🤝 Contributing

Found a bug or have a suggestion? Feel free to open an issue or submit a pull request!

## 📜 License

MIT License - feel free to use these configs however you'd like!

---

**Made with ❤️ for productive development environments**
#!/bin/bash

# Hyprland Dotfiles Installation Script
# Sets up symlinks and installs packages for Hyprland on Arch Linux

set -e  # Exit on any error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$HOME/.config"

echo "🌊 Setting up dotfiles for Hyprland (Wayland)..."
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Config directory: $CONFIG_DIR"

# Function to check if running on Arch Linux
is_arch() {
    [[ -f /etc/arch-release ]] || [[ -f /etc/pacman.conf ]]
}

# Function to check if package is installed
is_package_installed() {
    if is_arch; then
        pacman -Qi "$1" &> /dev/null
    else
        command -v "$1" &> /dev/null
    fi
}

# Helper function to check which packages are missing
check_missing_packages() {
    local packages=("$@")
    local missing_packages=()

    echo "📦 Checking for required packages..." >&2

    # Check which packages are missing
    for pkg in "${packages[@]}"; do
        if ! is_package_installed "$pkg"; then
            missing_packages+=("$pkg")
            echo "  ❌ $pkg not found" >&2
        else
            echo "  ✅ $pkg already installed" >&2
        fi
    done

    # Return missing packages array to stdout (for mapfile to capture)
    printf '%s\n' "${missing_packages[@]}"
}

# Function to install pacman packages
pacman_install_packages() {
    local packages=("$@")
    local missing_packages

    # Get missing packages using helper function
    mapfile -t missing_packages < <(check_missing_packages "${packages[@]}")

    # Install missing packages
    if [[ ${#missing_packages[@]} -gt 0 && -n "${missing_packages[0]}" ]]; then
        echo ""
        echo "Installing missing packages: ${missing_packages[*]}"

        if is_arch; then
            echo "Running: sudo pacman -S --needed ${missing_packages[*]}"
            sudo pacman -S --needed "${missing_packages[@]}"
        else
            echo "⚠️  Non-Arch system detected. Please install these packages manually:"
            printf "  - %s\n" "${missing_packages[@]}"
            echo ""
            read -p "Continue with setup? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Setup cancelled."
                exit 1
            fi
        fi
        echo "✅ Package installation complete!"
    else
        echo "✅ All required packages are already installed!"
    fi
    echo ""
}

# Function to install yay if not already installed
install_yay() {
    if command -v yay &> /dev/null; then
        echo "✅ yay is already installed"
        return 0
    fi

    echo "📦 Installing yay AUR helper..."
    echo "yay is required to install AUR packages"

    # Install dependencies
    sudo pacman -S --needed git base-devel

    # Clone and build yay
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd -
    rm -rf "$temp_dir"

    if command -v yay &> /dev/null; then
        echo "✅ yay installed successfully"
    else
        echo "❌ Failed to install yay"
        return 1
    fi
}

# Function to install AUR packages
aur_install_packages() {
    local packages=("$@")
    local missing_packages

    # Get missing packages using helper function
    mapfile -t missing_packages < <(check_missing_packages "${packages[@]}")

    # Install missing packages
    if [[ ${#missing_packages[@]} -gt 0 && -n "${missing_packages[0]}" ]]; then
        echo ""
        echo "Installing missing packages: ${missing_packages[*]}"

        if is_arch; then
            echo "Running: yay -S --needed ${missing_packages[*]}"
            yay -S --needed "${missing_packages[@]}"
        else
            echo "⚠️  Non-Arch system detected. Please install these packages manually:"
            printf "  - %s\n" "${missing_packages[@]}"

            echo ""
            read -p "Continue with setup? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Setup cancelled."
                exit 1
            fi
        fi
        echo "✅ Package installation complete!"
    else
        echo "✅ All required packages are already installed!"
    fi
    echo ""
}

# Required packages for Hyprland setup
PACMAN_REQUIRED_PACKAGES=(
    # Core Hyprland components
    "hyprland"           # Hyprland compositor
    "hyprpaper"          # Wallpaper daemon for Hyprland
    "hypridle"           # Idle daemon for Hyprland
    "hyprlock"           # Screen locker for Hyprland
    "xdg-desktop-portal-hyprland"  # XDG desktop portal
    "qt5-wayland"        # Qt5 Wayland support
    "qt6-wayland"        # Qt6 Wayland support

    # Status bar and launcher
    "waybar"             # Status bar for Wayland
    "rofi-wayland"       # Application launcher (Wayland fork)

    # Notification and system daemons
    "dunst"              # Notification daemon (works on Wayland)
    "pipewire"           # Audio system
    "wireplumber"        # Pipewire session manager
    "brightnessctl"      # Brightness control

    # Screenshot and clipboard tools
    "grim"               # Screenshot tool for Wayland
    "slurp"              # Region selector for Wayland
    "wl-clipboard"       # Clipboard utilities for Wayland
    "cliphist"           # Clipboard history for Wayland

    # Terminal and basic tools
    "ghostty"            # Terminal emulator (Wayland-ready)
    "git"                # For neovim config
    "neovim"             # Text editor
    "tmux"               # Terminal multiplexer

    # File management
    "yazi"               # File manager
    "ffmpeg"             # Video converter
    "7zip"               # Archive tool
    "unzip"              # Archive tool
    "zip"                # Archive tool
    "tar"                # Archive tool
    "gzip"               # Archive tool
    "jq"                 # JSON processor
    "fd"                 # File finder
    "bat"                # Cat alternative
    "fzf"                # Fuzzy finder
    "zoxide"             # Directory jumper
    "imagemagick"        # Image manipulation
    "ripgrep"            # Search tool

    # System utilities
    "btop"               # System monitor
    "polkit-gnome"       # Authentication agent
    "network-manager-applet"  # Network manager

    # Applications
    "spotify-launcher"   # Spotify
    "discord"            # Discord
    "docker"             # Docker
    "chromium"           # Chromium
    "firefox"            # Firefox

    # Fonts
    "ttf-dejavu"         # DejaVu Sans Mono
    "ttf-jetbrains-mono-nerd"  # JetBrains Mono Nerd Font

    # VPN
    "wireguard-tools"    # WireGuard
    "openresolv"         # Openresolv

    # Fun
    "cmatrix"            # ASCII art matrix
)

AUR_REQUIRED_PACKAGES=(
    "hyprland-autotile"  # Auto-tiling for Hyprland
    "cursor-bin"         # Cursor IDE
    "postman-bin"        # Postman
    "docker-desktop"     # Docker Desktop
    "pipes.sh"           # Pipes.sh
    "oh-my-posh"         # Oh My Posh
    "resvg"              # SVG preview (for yazi)
)

# Install required packages
pacman_install_packages "${PACMAN_REQUIRED_PACKAGES[@]}"

# Install yay if needed (before AUR packages)
install_yay

# Install AUR packages
aur_install_packages "${AUR_REQUIRED_PACKAGES[@]}"

# Create .config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

echo "Creating screenshots directory..."
mkdir -p "$HOME/Pictures/Screenshots"

# Function to create symlink safely
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"

    echo "Setting up $name..."

    # Remove existing file/directory/symlink
    if [[ -e "$target" || -L "$target" ]]; then
        echo "  Removing existing $target"
        rm -rf "$target"
    fi

    # Create symlink
    echo "  Creating symlink: $target -> $source"
    ln -s "$source" "$target"

    # Verify symlink was created successfully
    if [[ -L "$target" ]]; then
        echo "  ✅ $name symlink created successfully"
    else
        echo "  ❌ Failed to create $name symlink"
        return 1
    fi
}

# Setup Hyprland config
if [[ -d "$DOTFILES_DIR/hyprland" ]]; then
    create_symlink "$DOTFILES_DIR/hyprland" "$CONFIG_DIR/hypr" "hyprland"
else
    echo "⚠️  Warning: hyprland directory not found in dotfiles"
fi

# Setup Waybar config
if [[ -d "$DOTFILES_DIR/waybar" ]]; then
    create_symlink "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar" "waybar"
else
    echo "⚠️  Warning: waybar directory not found in dotfiles"
fi

# Setup rofi config (rofi-wayland compatible)
if [[ -d "$DOTFILES_DIR/rofi" ]]; then
    create_symlink "$DOTFILES_DIR/rofi" "$CONFIG_DIR/rofi" "rofi"
else
    echo "⚠️  Warning: rofi directory not found in dotfiles"
fi

# Setup ghostty config
if [[ -d "$DOTFILES_DIR/ghostty" ]]; then
    echo "  Generating ghostty config..."
    bash "$DOTFILES_DIR/ghostty/generate-config.sh"
    create_symlink "$DOTFILES_DIR/ghostty" "$CONFIG_DIR/ghostty" "ghostty"
else
    echo "⚠️  Warning: ghostty directory not found in dotfiles"
fi

# Setup GTK 3.0 config
if [[ -d "$DOTFILES_DIR/gtk-3.0" ]]; then
    create_symlink "$DOTFILES_DIR/gtk-3.0" "$CONFIG_DIR/gtk-3.0" "gtk-3.0"
else
    echo "⚠️  Warning: gtk-3.0 directory not found in dotfiles"
fi

# Setup GTK 4.0 config
if [[ -d "$DOTFILES_DIR/gtk-4.0" ]]; then
    create_symlink "$DOTFILES_DIR/gtk-4.0" "$CONFIG_DIR/gtk-4.0" "gtk-4.0"
else
    echo "⚠️  Warning: gtk-4.0 directory not found in dotfiles"
fi

# Setup neovim config
echo "Setting up neovim..."
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

# Remove existing neovim config if it exists
if [[ -e "$NVIM_CONFIG_DIR" || -L "$NVIM_CONFIG_DIR" ]]; then
    echo "  Removing existing $NVIM_CONFIG_DIR"
    rm -rf "$NVIM_CONFIG_DIR"
fi

# Clone kickstart.nvim
echo "  Cloning kickstart.nvim configuration..."
if git clone https://github.com/brianmatzelle/kickstart.nvim.git "$NVIM_CONFIG_DIR"; then
    echo "  ✅ neovim configuration cloned successfully"
else
    echo "  ❌ Failed to clone neovim configuration"
fi

# Set GNOME/GTK dark mode preference
echo "Setting dark mode preference..."
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    echo "  ✅ Dark mode preference set"
else
    echo "  ⚠️  gsettings not available, skipping dark mode preference"
fi

# Enable Hyprland session
echo ""
echo "🎉 Hyprland dotfiles installation complete!"
echo ""
echo "Symlinks created:"
ls -la "$CONFIG_DIR" | grep -E "(hypr|waybar|rofi|ghostty|gtk)" || echo "No config symlinks found"
echo ""
echo "Neovim config:"
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    echo "✅ Neovim configuration installed at $NVIM_CONFIG_DIR"
else
    echo "❌ Neovim configuration not found"
fi
echo ""
echo "📋 Next steps:"
echo "1. Log out of your current session"
echo "2. At the login screen, select 'Hyprland' as your session type"
echo "3. Log in and enjoy Wayland!"
echo ""
echo "💡 Tips:"
echo "  - Mod key is Super (Windows key)"
echo "  - Press Mod+Return to open a terminal"
echo "  - Press Mod+D to open the application launcher"
echo "  - See HYPRLAND_MIGRATION.md for full keybinding reference"

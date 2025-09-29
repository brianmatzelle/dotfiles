#!/bin/bash

# Dotfiles Installation Script
# Sets up symlinks from ~/.config to dotfiles repo

set -e  # Exit on any error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "🔗 Setting up dotfiles..."
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

# Required packages for the dotfiles setup
PACMAN_REQUIRED_PACKAGES=(
    "i3-wm"              # i3 window manager
    "polybar"            # Status bar
    "rofi"               # Application launcher
    "picom"              # Compositor for transparency
    "nitrogen"           # Wallpaper setter
    "dunst"              # Notification daemon
    "pipewire"           # Audio system
    "xss-lock"           # Screen lock on suspend
    "i3lock"             # Screen locker
    "autotiling"         # Auto-tiling for i3
    "brightnessctl"      # Brightness control
    "scrot"              # Screenshot tool
    "ddcutil"            # Display control (for brightness)
    "git"                # For neovim config
    "neovim"             # Text editor
    "ghostty"            # System monitor
    "cmatrix"            # ASCII art matrix
    "tmux"               # Terminal multiplexer
    "yay"                # AUR helper
    "feh"                # Image viewer
    "ripgrep"            # Search tool
    # begin yazi deps
    "yazi"               # File manager
    "ffmpeg"             # Video converter
    "7zip"
    "unzip"              # Archive tool
    "zip"                # Archive tool
    "tar"                # Archive tool
    "gzip"               # Archive tool
    "jq"                 # JSON processor
    "fd"                 # File finder
    "bat"                # Cat alternative
    "btop"               # System monitor
    "fzf"                # File finder
    "zoxide"             # Directory jumper
    "resvg"              # SVG preview
    "imagemagick"        # Image manipulation
    "xclip"
    # end yazi deps
    "spotify-launcher"     # Spotify
    "discord"              # Discord
    "docker"               # Docker, docker-compose is installed by AUR docker-desktop
    "chromium"             # Chromium
)

AUR_REQUIRED_PACKAGES=(
    "cursor-bin"         # Cursor 
    "postman-bin"        # Postman
    "docker-desktop"     # Docker Desktop
    "pipes.sh"             # Pipes.sh
    "oh-my-posh"           # Oh My Posh
    "google-chrome"        # Google Chrome
)

# Install required packages
pacman_install_packages "${PACMAN_REQUIRED_PACKAGES[@]}"

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

# Setup rofi config
if [[ -d "$DOTFILES_DIR/rofi" ]]; then
    create_symlink "$DOTFILES_DIR/rofi" "$CONFIG_DIR/rofi" "rofi"
else
    echo "⚠️  Warning: rofi directory not found in dotfiles"
fi

# Setup i3 config
if [[ -d "$DOTFILES_DIR/i3" ]]; then
    create_symlink "$DOTFILES_DIR/i3" "$CONFIG_DIR/i3" "i3"
else
    echo "⚠️  Warning: i3 directory not found in dotfiles"
fi

# Setup ghostty config
if [[ -d "$DOTFILES_DIR/ghostty" ]]; then
    create_symlink "$DOTFILES_DIR/ghostty" "$CONFIG_DIR/ghostty" "ghostty"
else
    echo "⚠️  Warning: ghostty directory not found in dotfiles"
fi

# Setup polybar config
if [[ -d "$DOTFILES_DIR/polybar" ]]; then
    create_symlink "$DOTFILES_DIR/polybar" "$CONFIG_DIR/polybar" "polybar"
else
    echo "⚠️  Warning: polybar directory not found in dotfiles"
fi

# Setup picom config
if [[ -f "$DOTFILES_DIR/picom/picom.conf" ]]; then
    create_symlink "$DOTFILES_DIR/picom/picom.conf" "$CONFIG_DIR/picom.conf" "picom"
else
    echo "⚠️  Warning: picom config not found in dotfiles"
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

echo ""
echo "🎉 Dotfiles installation complete!"
echo ""
echo "Symlinks created:"
ls -la "$CONFIG_DIR" | grep -E "(rofi|i3|ghostty|polybar|picom)" || echo "No config symlinks found"
echo ""
echo "Neovim config:"
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    echo "✅ Neovim configuration installed at $NVIM_CONFIG_DIR"
else
    echo "❌ Neovim configuration not found"
fi
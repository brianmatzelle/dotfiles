#!/bin/bash

# Debian Server Dotfiles Installation Script
# Sets up symlinks and installs packages for a headless Debian server

set -e  # Exit on any error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$HOME/.config"

echo "🐧 Setting up dotfiles for Debian server..."
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Config directory: $CONFIG_DIR"

# Function to check if running on Debian
is_debian() {
    [[ -f /etc/debian_version ]]
}

if ! is_debian; then
    echo "❌ This script is intended for Debian-based systems"
    exit 1
fi

# Function to check if package is installed
is_package_installed() {
    dpkg -s "$1" &> /dev/null
}

# Helper function to check which packages are missing
check_missing_packages() {
    local packages=("$@")
    local missing_packages=()

    echo "📦 Checking for required packages..." >&2

    for pkg in "${packages[@]}"; do
        if ! is_package_installed "$pkg"; then
            missing_packages+=("$pkg")
            echo "  ❌ $pkg not found" >&2
        else
            echo "  ✅ $pkg already installed" >&2
        fi
    done

    printf '%s\n' "${missing_packages[@]}"
}

# Function to install apt packages
apt_install_packages() {
    local packages=("$@")
    local missing_packages

    mapfile -t missing_packages < <(check_missing_packages "${packages[@]}")

    if [[ ${#missing_packages[@]} -gt 0 && -n "${missing_packages[0]}" ]]; then
        echo ""
        echo "Installing missing packages: ${missing_packages[*]}"
        echo "Running: sudo apt install -y ${missing_packages[*]}"
        sudo apt update
        sudo apt install -y "${missing_packages[@]}"
        echo "✅ Package installation complete!"
    else
        echo "✅ All required packages are already installed!"
    fi
    echo ""
}

# Server-relevant packages (Debian names)
APT_REQUIRED_PACKAGES=(
    # Core tools
    "git"                # Version control
    "neovim"             # Text editor
    "tmux"               # Terminal multiplexer
    "curl"               # HTTP client
    "wget"               # HTTP client

    # Search & navigation
    "ripgrep"            # Fast grep (rg)
    "fd-find"            # Fast find (fdfind on Debian)
    "fzf"                # Fuzzy finder
    "jq"                 # JSON processor

    # Modern CLI tools
    "bat"                # Cat alternative (batcat on Debian)
    "btop"               # System monitor

    # Archive tools
    "unzip"              # Archive tool
    "zip"                # Archive tool

    # Server essentials
    "wireguard-tools"    # WireGuard VPN
    "docker.io"          # Docker
    "docker-compose"     # Docker Compose

    # Fun
    "cmatrix"            # Matrix screensaver

    # Build essentials (for compiling tools if needed)
    "build-essential"    # gcc, make, etc.
)

# Install packages
apt_install_packages "${APT_REQUIRED_PACKAGES[@]}"

# Install zoxide (not in Debian repos, use official installer)
if ! command -v zoxide &> /dev/null; then
    echo "📦 Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    echo "✅ zoxide installed"
else
    echo "✅ zoxide already installed"
fi
echo ""

# Create .config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

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

# Setup tmux config (server profile)
if [[ -f "$DOTFILES_DIR/tmux/server.tmux.conf" ]]; then
    create_symlink "$DOTFILES_DIR/tmux/server.tmux.conf" "$HOME/.tmux.conf" "tmux (server)"
else
    echo "⚠️  Warning: tmux/server.tmux.conf not found in dotfiles"
fi

# Setup neovim config
echo "Setting up neovim..."
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

if [[ -e "$NVIM_CONFIG_DIR" || -L "$NVIM_CONFIG_DIR" ]]; then
    echo "  Removing existing $NVIM_CONFIG_DIR"
    rm -rf "$NVIM_CONFIG_DIR"
fi

echo "  Cloning kickstart.nvim configuration..."
if git clone https://github.com/brianmatzelle/kickstart.nvim.git "$NVIM_CONFIG_DIR"; then
    echo "  ✅ neovim configuration cloned successfully"
else
    echo "  ❌ Failed to clone neovim configuration"
fi

# Setup universal aliases in .bash_aliases
echo "Setting up bash aliases..."
BASH_ALIASES_FILE="$HOME/.bash_aliases"
ALIASES_SOURCE="$DOTFILES_DIR/zsh/universal_aliases.sh"
SOURCE_LINE="source \"$ALIASES_SOURCE\""

if [[ -f "$ALIASES_SOURCE" ]]; then
    # Create .bash_aliases if it doesn't exist
    touch "$BASH_ALIASES_FILE"

    # Add source line if not already present
    if ! grep -qF "$ALIASES_SOURCE" "$BASH_ALIASES_FILE"; then
        echo "" >> "$BASH_ALIASES_FILE"
        echo "# Universal aliases from dotfiles" >> "$BASH_ALIASES_FILE"
        echo "$SOURCE_LINE" >> "$BASH_ALIASES_FILE"
        echo "  ✅ Universal aliases sourced in $BASH_ALIASES_FILE"
    else
        echo "  ✅ Universal aliases already configured"
    fi
else
    echo "  ⚠️  Warning: universal_aliases.sh not found in dotfiles"
fi

# Handle Debian-specific binary name differences
echo ""
echo "Setting up Debian compatibility aliases..."
COMPAT_MARKER="# Debian compatibility aliases from dotfiles"
if ! grep -qF "$COMPAT_MARKER" "$BASH_ALIASES_FILE"; then
    cat >> "$BASH_ALIASES_FILE" << 'EOF'

# Debian compatibility aliases from dotfiles
# fd is named fd-find on Debian
if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    alias fd="fdfind"
fi
# bat is named batcat on Debian
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    alias bat="batcat"
fi
EOF
    echo "  ✅ Debian compatibility aliases added"
else
    echo "  ✅ Debian compatibility aliases already configured"
fi

# Add zoxide init to bashrc if installed
echo ""
echo "Setting up zoxide..."
ZOXIDE_MARKER="# zoxide init from dotfiles"
if command -v zoxide &> /dev/null; then
    if ! grep -qF "$ZOXIDE_MARKER" "$HOME/.bashrc"; then
        cat >> "$HOME/.bashrc" << 'EOF'

# zoxide init from dotfiles
eval "$(zoxide init bash)"
EOF
        echo "  ✅ zoxide init added to .bashrc"
    else
        echo "  ✅ zoxide already configured in .bashrc"
    fi
else
    echo "  ⚠️  zoxide not found, skipping bashrc init"
fi

# Install Claude Code (native binary)
echo ""
echo "Setting up Claude Code..."
if command -v claude &> /dev/null; then
    echo "  ✅ Claude Code already installed ($(claude --version 2>/dev/null || echo 'unknown version'))"
else
    echo "  Installing Claude Code via native installer..."
    curl -fsSL https://claude.ai/install.sh | bash
    if command -v claude &> /dev/null || [[ -x "$HOME/.local/bin/claude" ]]; then
        echo "  ✅ Claude Code installed successfully"
    else
        echo "  ❌ Failed to install Claude Code"
    fi
fi

# Install Tailscale
echo ""
echo "Setting up Tailscale..."
if command -v tailscale &> /dev/null; then
    echo "  ✅ Tailscale already installed ($(tailscale version 2>/dev/null | head -1 || echo 'unknown version'))"
else
    echo "  Installing Tailscale via official installer..."
    curl -fsSL https://tailscale.com/install.sh | sh
    if command -v tailscale &> /dev/null; then
        echo "  ✅ Tailscale installed successfully"
    else
        echo "  ❌ Failed to install Tailscale"
    fi
fi

# Enable and start tailscaled service
echo "  Enabling tailscaled service..."
sudo systemctl enable --now tailscaled
echo "  ✅ tailscaled service enabled and running"

# Add user to docker group
echo ""
echo "Setting up Docker..."
if groups "$USER" | grep -q docker; then
    echo "  ✅ User already in docker group"
else
    echo "  Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    echo "  ✅ Added to docker group (log out and back in to take effect)"
fi

echo ""
echo "🎉 Debian server dotfiles installation complete!"
echo ""
echo "Summary:"
echo "  - tmux:       server profile symlinked to ~/.tmux.conf"
echo "  - neovim:     kickstart.nvim cloned to ~/.config/nvim"
echo "  - aliases:    universal aliases sourced in ~/.bash_aliases"
echo "  - zoxide:     initialized in ~/.bashrc"
echo "  - claude:     Claude Code CLI installed"
echo "  - tailscale:  installed and tailscaled service enabled"
echo "  - docker:     user added to docker group"
echo ""
echo "⚠️  Note: Debian ships older versions of some tools."
echo "   If you need bat/fd by their standard names, the compatibility"
echo "   aliases in ~/.bash_aliases handle this automatically."
echo ""

# Print server IPs
echo "🌐 Server IPs:"
PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "unavailable")
echo "  Public IP: $PUBLIC_IP"

if tailscale status &> /dev/null; then
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "unavailable")
    echo "  Tailscale IP: $TAILSCALE_IP"
    echo ""
    echo "  Friends can reach your services at:"
    echo "    Web apps:    $TAILSCALE_IP:3000 - $TAILSCALE_IP:3010"
    echo "    Backends:    $TAILSCALE_IP:8000 - $TAILSCALE_IP:8099"
    echo "    Minecraft:   $TAILSCALE_IP:25565"
else
    echo "  Tailscale IP: not yet authenticated"
    echo ""
    echo "⚡ Next step — authenticate Tailscale:"
    echo "   sudo tailscale up"
    echo ""
    echo "   This will print a login URL. Open it in your browser to"
    echo "   connect this server to your tailnet."
fi

echo ""
echo "🔄 Run 'source ~/.bashrc' or start a new shell to apply changes."

#!/bin/bash

# macOS Dotfiles Installation Script
# Sets up symlinks for macOS-compatible configurations

set -e  # Exit on any error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "🍎 Setting up dotfiles for macOS..."
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Config directory: $CONFIG_DIR"

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

# Setup ghostty config (macOS-compatible)
if [[ -d "$DOTFILES_DIR/ghostty" ]]; then
    # Generate OS-specific config
    echo "  Generating macOS-specific ghostty config..."
    if [[ -f "$DOTFILES_DIR/ghostty/generate-config.sh" ]]; then
        bash "$DOTFILES_DIR/ghostty/generate-config.sh"
    fi
    create_symlink "$DOTFILES_DIR/ghostty" "$CONFIG_DIR/ghostty" "ghostty"
else
    echo "⚠️  Warning: ghostty directory not found in dotfiles"
fi

# Setup tmux config (cross-platform)
if [[ -d "$DOTFILES_DIR/tmux" ]]; then
    create_symlink "$DOTFILES_DIR/tmux" "$CONFIG_DIR/tmux" "tmux"
else
    echo "⚠️  Warning: tmux directory not found in dotfiles"
fi

# Setup neovim config (cross-platform)
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
echo "🎉 macOS dotfiles installation complete!"
echo ""
echo "Configurations set up:"
echo "  ✅ Ghostty (with macOS-specific window decorations)"
echo "  ✅ Tmux (cross-platform terminal multiplexer)"
echo "  ✅ Neovim (cross-platform editor)"
echo ""
echo "Note: Linux-specific configs (i3, polybar, rofi, picom) are not installed on macOS"
echo ""
echo "Symlinks created:"
ls -la "$CONFIG_DIR" | grep -E "(ghostty|tmux)" || echo "No config symlinks found"
echo ""
echo "Neovim config:"
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    echo "✅ Neovim configuration installed at $NVIM_CONFIG_DIR"
else
    echo "❌ Neovim configuration not found"
fi

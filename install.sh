#!/bin/bash

# Dotfiles Installation Script
# Sets up symlinks from ~/.config to dotfiles repo

set -e  # Exit on any error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "🔗 Setting up dotfiles symlinks..."
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

echo ""
echo "🎉 Dotfiles installation complete!"
echo ""
echo "Symlinks created:"
ls -la "$CONFIG_DIR" | grep -E "(rofi|i3)" || echo "No symlinks found"
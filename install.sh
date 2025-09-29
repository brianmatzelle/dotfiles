#!/bin/bash

# Dotfiles Installation Script
# Detects OS and runs the appropriate installation script

set -e  # Exit on any error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Dotfiles Installation"
echo "========================"
echo ""

# Function to detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    elif [[ -f /etc/arch-release ]] || [[ -f /etc/pacman.conf ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "redhat"
    else
        echo "unknown"
    fi
}

# Detect the current operating system
OS=$(detect_os)
echo "Detected OS: $OS"
echo ""

# Run the appropriate installation script
case "$OS" in
    "macOS")
        echo "🍎 Running macOS installation script..."
        if [[ -f "$DOTFILES_DIR/install_mac.sh" ]]; then
            chmod +x "$DOTFILES_DIR/install_mac.sh"
            bash "$DOTFILES_DIR/install_mac.sh"
        else
            echo "❌ Error: install_mac.sh not found"
            exit 1
        fi
        ;;
    "arch")
        echo "🐧 Running Arch Linux installation script..."
        if [[ -f "$DOTFILES_DIR/install_arch.sh" ]]; then
            chmod +x "$DOTFILES_DIR/install_arch.sh"
            bash "$DOTFILES_DIR/install_arch.sh"
        else
            echo "❌ Error: install_arch.sh not found"
            exit 1
        fi
        ;;
    "debian"|"redhat")
        echo "⚠️  $OS detected but not currently supported"
        echo "This dotfiles setup is currently designed for:"
        echo "  - macOS (limited config support)"
        echo "  - Arch Linux (full config support)"
        echo ""
        echo "You can manually run install_arch.sh if you want to attempt"
        echo "the Arch Linux setup on your $OS system."
        exit 1
        ;;
    "unknown")
        echo "❌ Unknown operating system detected"
        echo "Supported systems:"
        echo "  - macOS: install_mac.sh"
        echo "  - Arch Linux: install_arch.sh"
        echo ""
        echo "Please run the appropriate script manually:"
        echo "  ./install_mac.sh    (for macOS)"
        echo "  ./install_arch.sh   (for Arch Linux)"
        exit 1
        ;;
esac

echo ""
echo "✨ Installation completed successfully!"
#!/bin/bash

# macOS Dotfiles Installation Script
# Sets up symlinks and installs packages for macOS

set -e  # Exit on any error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "🍎 Setting up dotfiles for macOS..."
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Config directory: $CONFIG_DIR"

# Function to check if Homebrew is installed
is_homebrew_installed() {
    command -v brew &> /dev/null
}

# Function to install Homebrew
install_homebrew() {
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        # Apple Silicon Mac
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    echo "✅ Homebrew installed successfully!"
}

# Function to check if package is installed
is_package_installed() {
    brew list "$1" &> /dev/null
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

# Function to install Homebrew packages
brew_install_packages() {
    local packages=("$@")
    local missing_packages
    
    # Get missing packages using helper function
    mapfile -t missing_packages < <(check_missing_packages "${packages[@]}")
    
    # Install missing packages
    if [[ ${#missing_packages[@]} -gt 0 && -n "${missing_packages[0]}" ]]; then
        echo ""
        echo "Installing missing packages: ${missing_packages[*]}"
        echo "Running: brew install ${missing_packages[*]}"
        brew install "${missing_packages[@]}"
        echo "✅ Package installation complete!"
    else
        echo "✅ All required packages are already installed!"
    fi
    echo ""
}

# Check and install Homebrew if needed
if ! is_homebrew_installed; then
    echo "Homebrew not found. Installing..."
    install_homebrew
else
    echo "✅ Homebrew is already installed"
    # Update Homebrew
    echo "🔄 Updating Homebrew..."
    brew update
fi

# Required packages for the dotfiles setup
BREW_REQUIRED_PACKAGES=(
    "git"                # For neovim config and general development
    "neovim"             # Text editor
    "tmux"               # Terminal multiplexer
    "cmatrix"            # ASCII art matrix
    "btop"               # System monitor
    "pipes-sh"           # Animated pipes screensaver
    "ripgrep"            # Search tool
    "fzf"                # Fuzzy finder
    "bat"                # Cat alternative
    "fd"                 # File finder
    "zoxide"             # Directory jumper
    "jq"                 # JSON processor
    "asciiquarium"       # Asciiquarium!
    "ghostty"            # Terminal emulator
    "jandedobbeleer/oh-my-posh/oh-my-posh"         # Oh My Posh
    "font-fira-code-nerd-font"                     # Nerd font
)

# Install required packages
brew_install_packages "${BREW_REQUIRED_PACKAGES[@]}"

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

# Setup tmux config (macOS-specific work config)
if [[ -d "$DOTFILES_DIR/tmux" ]]; then
    create_symlink "$DOTFILES_DIR/tmux" "$CONFIG_DIR/tmux" "tmux directory"
    # Create symlink to work.tmux.conf as tmux.conf
    if [[ -f "$DOTFILES_DIR/tmux/work.tmux.conf" ]]; then
        create_symlink "$DOTFILES_DIR/tmux/work.tmux.conf" "$HOME/.tmux.conf" "tmux work config"
    else
        echo "⚠️  Warning: work.tmux.conf not found in tmux directory"
    fi
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

# Setup oh-my-posh in .zshrc
echo "Setting up oh-my-posh..."
ZSHRC_FILE="$HOME/.zshrc"
OH_MY_POSH_CONFIG='eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/amro.omp.json)"'

# Check if oh-my-posh config already exists in .zshrc
if [[ -f "$ZSHRC_FILE" ]] && grep -q "oh-my-posh init" "$ZSHRC_FILE"; then
    echo "  ✅ oh-my-posh configuration already exists in .zshrc"
else
    # Create .zshrc if it doesn't exist
    if [[ ! -f "$ZSHRC_FILE" ]]; then
        touch "$ZSHRC_FILE"
        echo "  Created .zshrc file"
    fi
    
    # Append oh-my-posh configuration
    echo "" >> "$ZSHRC_FILE"
    echo "# oh-my-posh" >> "$ZSHRC_FILE"
    echo "$OH_MY_POSH_CONFIG" >> "$ZSHRC_FILE"
    echo "" >> "$ZSHRC_FILE"
    echo "  ✅ oh-my-posh configuration added to .zshrc"
fi

echo ""
echo "🎉 macOS dotfiles installation complete!"
echo ""
echo "Installed packages:"
echo "  ✅ Core tools: git, neovim, tmux, ripgrep, fzf, bat, fd, zoxide, jq"
echo "  ✅ Fun tools: cmatrix, btop, pipes-sh"
echo "  ✅ Shell tools: oh-my-posh"
echo ""
echo "Configurations set up:"
echo "  ✅ Ghostty (with macOS-specific window decorations)"
echo "  ✅ Tmux (cross-platform terminal multiplexer)"
echo "  ✅ Neovim (cross-platform editor)"
echo "  ✅ oh-my-posh (shell prompt theme in ~/.zshrc)"
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

echo ""
echo "🍺 Homebrew packages installed. You can add more packages to the"
echo "   BREW_REQUIRED_PACKAGES array in install_mac.sh as needed."

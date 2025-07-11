# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing shell configurations, tmux settings, and custom utility functions for macOS development environment setup.

## Key Components

### Shell Configuration
- **zsh/work.zshrc**: Main zsh configuration with environment variables, PATH setup, and tool integrations
- **zsh/work.zsh_aliases**: Development aliases for git, yarn, tmux, Python, and workflow shortcuts
- **zsh/work.zsh_functions**: Custom shell functions for development tasks
- **zsh/universal**: Currently empty, intended for universal configurations

### Tmux Configuration
- **tmux/work.tmux.conf**: Feature-rich tmux config with Catppuccin Frappe theme, vim-like keybindings, and enhanced productivity features
- **tmux/server.tmux.conf**: Minimal tmux config with red/yellow color scheme for server environments

### Setup
- **setup**: Basic bash script for initializing dotfile configurations

## Common Commands and Aliases

### Development Workflow
- `reload`: Reload zsh configuration
- `edit-zshrc`, `edit-aliases`, `edit-functions`: Edit configuration files
- `ct`: Clear terminal and show task list
- `ts`: Create or attach to default tmux session

### Git Operations
- `gcm`: Git commit with message
- `main`: Switch to main branch
- `lsmbs`: List branches with "matzelle/" prefix
- `rebase`: Interactive rebase with main branch (includes safety prompts)

### Python Development
- `av`: Activate virtual environment (looks for venv or .venv)
- `pt`: Run pytest with pipenv
- `ptk <test>`: Run specific test by name
- `ptkh <test>`: Run specific test in headed mode
- `cleanpyc`: Remove all __pycache__ directories

### Tmux Session Management
- `tn <name>`: Create new tmux session
- `ta <name>`: Attach to tmux session
- `tk <name>`: Kill tmux session
- `trs <session> <name>`: Rename tmux session
- `tnc <name>`: Create new session with predefined layout (nvim + task panes)

### Docker Development
- `d`, `dpt`, `dptk`, `dptkh`: Docker compose commands for running tests (must be in qatests directory)

### Utility Functions
- `f_size <path>`: Get folder size
- `over100mb <path>`: Find files over 100MB
- `jasypt [encrypt|decrypt]`: Jasypt encryption/decryption wrapper
- `ai [-m model] <prompt>`: Query local Ollama instance
- `update_p [-m message]`: Update production repository with timestamp

## Environment Setup

The configuration includes extensive PATH modifications and tool integrations:
- SDKMAN for Java version management
- Node.js (v20) via Homebrew
- Python via Anaconda/Conda
- Bun runtime
- NVM for Node version management
- Various development tools (Maven, Spicetify, etc.)

## Key Features

### Tmux Enhancements
- Vim-like navigation (hjkl)
- Mouse support enabled
- Custom status bar with system information
- Copy mode optimizations
- Automatic window renaming

### Shell Productivity
- oh-my-posh prompt with amro theme
- Extensive alias system for common operations
- Auto-completion for various tools
- Environment variable management via ~/.env

## Development Patterns

When working with this repository:
1. Configuration files follow a work/personal separation pattern
2. Functions include usage validation and error handling
3. Interactive prompts for potentially destructive operations (like force push)
4. Consistent naming conventions for related functions
5. Environment-specific configurations (work vs server tmux configs)

## Authentication Tokens

The aliases file contains various authentication token retrieval commands for different environments (stage, UAT, training, production) - these are work-specific utilities for API access.
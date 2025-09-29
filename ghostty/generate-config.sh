#!/bin/bash

# Script to generate OS-specific Ghostty config
# This script reads the config.template and generates the actual config file
# based on the current operating system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/config.template"
OUTPUT_FILE="$SCRIPT_DIR/config"

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use native window decorations
    WINDOW_DECORATION="true"
    GTK_TITLEBAR="false"
    echo "Detected macOS - enabling window decorations"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - let window manager handle decorations
    WINDOW_DECORATION="false"
    GTK_TITLEBAR="false"
    echo "Detected Linux - disabling window decorations"
else
    # Default fallback
    WINDOW_DECORATION="false"
    GTK_TITLEBAR="false"
    echo "Unknown OS ($OSTYPE) - using default settings"
fi

# Generate the config file from template
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Error: Template file not found at $TEMPLATE_FILE"
    exit 1
fi

# Replace placeholders with OS-specific values
sed -e "s/{{WINDOW_DECORATION}}/$WINDOW_DECORATION/g" \
    -e "s/{{GTK_TITLEBAR}}/$GTK_TITLEBAR/g" \
    "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE with OS-specific settings"
echo "  window-decoration = $WINDOW_DECORATION"
echo "  gtk-titlebar = $GTK_TITLEBAR"

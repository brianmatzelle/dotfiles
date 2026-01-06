#!/bin/bash
# Get current brightness percentage for waybar

# Try brightnessctl first (for laptop backlight)
if command -v brightnessctl &> /dev/null; then
    BRIGHTNESS=$(brightnessctl get)
    MAX=$(brightnessctl max)
    PERCENT=$((BRIGHTNESS * 100 / MAX))
    echo "${PERCENT}%"
    exit 0
fi

# Fallback to ddcutil for external monitors
if command -v ddcutil &> /dev/null; then
    BRIGHTNESS=$(ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\s+\K\d+')
    if [ -n "$BRIGHTNESS" ]; then
        echo "${BRIGHTNESS}%"
        exit 0
    fi
fi

# If neither works, show N/A
echo "N/A"

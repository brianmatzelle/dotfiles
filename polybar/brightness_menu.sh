#!/bin/bash

# Check if rofi is available
if ! command -v rofi &> /dev/null; then
    echo "rofi not found, falling back to cycling presets"
    # Fallback to cycling through presets
    PRESETS=(10 25 50 75 100)
    CURRENT=$(ddcutil getvcp 10 | grep -oP 'current value =\s*\K\d+')
    NEXT_INDEX=0
    for i in "${!PRESETS[@]}"; do
        if [ "${PRESETS[$i]}" -gt "$CURRENT" ]; then
            NEXT_INDEX=$i
            break
        fi
    done
    if [ $NEXT_INDEX -eq 0 ] && [ "$CURRENT" -ge "${PRESETS[-1]}" ]; then
        NEXT_INDEX=0
    fi
    ddcutil setvcp 10 "${PRESETS[$NEXT_INDEX]}"
    exit 0
fi

# Get current brightness
CURRENT=$(ddcutil getvcp 10 | grep -oP 'current value =\s*\K\d+')

# Brightness options
OPTIONS="5%
10%
15%
20%
25%
30%
40%
50%
60%
70%
80%
90%
100%"

# Show rofi menu
CHOICE=$(echo "$OPTIONS" | rofi -dmenu -p "Brightness" -theme-str 'window {width: 200px; height: 400px;}' -theme-str 'listview {lines: 10;}')

# Extract percentage value and set brightness
if [ -n "$CHOICE" ]; then
    PERCENTAGE=$(echo "$CHOICE" | sed 's/%//')
    ddcutil setvcp 10 "$PERCENTAGE"
fi

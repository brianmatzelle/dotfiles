#!/bin/bash

# Check if ddcutil is available and can detect displays
if ! command -v ddcutil &> /dev/null; then
    # ddcutil not installed, don't show brightness module
    exit 1
fi

# Check if any displays are detected
if ! ddcutil detect &> /dev/null; then
    # No displays detected, don't show brightness module
    exit 1
fi

# Try to get brightness value
BRIGHTNESS=$(ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K\d+')

if [ -z "$BRIGHTNESS" ]; then
    # Failed to get brightness, don't show module
    exit 1
fi

# Display found and brightness retrieved successfully
echo "${BRIGHTNESS}%"

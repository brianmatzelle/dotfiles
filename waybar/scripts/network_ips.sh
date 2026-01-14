#!/bin/bash

# Network IPs script for Waybar
# Shows Ethernet, WiFi, and VPN IPs with colored last octets

# Define interfaces and their colors for the last octet
declare -A interfaces=(
    ["eno1"]="#50FA7B"         # Green - Ethernet
    ["wlan0"]="#FF5555"        # Red - WiFi
    ["wg0-mullvad"]="#FFB86C"  # Orange - VPN
)

# Function to get IP for an interface
get_interface_ip() {
    local interface=$1
    ip addr show "$interface" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1
}

# Function to format IP with Pango markup for colored last octet
format_ip() {
    local ip=$1
    local color=$2

    if [ -n "$ip" ]; then
        # Split IP into octets
        IFS='.' read -r -a octets <<< "$ip"

        # Format with Pango: first three octets blue, last octet with interface color
        echo "<span color='#5F6FFC'>${octets[0]}.${octets[1]}.${octets[2]}.</span><span color='$color'>${octets[3]}</span>"
    fi
}

# Build output string
output_parts=()
tooltip_parts=()

# Check each interface
for interface in "${!interfaces[@]}"; do
    ip=$(get_interface_ip "$interface")

    if [ -n "$ip" ]; then
        color="${interfaces[$interface]}"
        formatted_ip=$(format_ip "$ip" "$color")

        # Add interface label and formatted IP
        case "$interface" in
            "eno1")
                label="ETH"
                ;;
            "wlan0")
                # Get WiFi ESSID if available
                essid=$(iwgetid -r 2>/dev/null)
                if [ -n "$essid" ]; then
                    label="$essid"
                else
                    label="WiFi"
                fi
                ;;
            "wg0-mullvad")
                label="VPN"
                ;;
        esac

        output_parts+=("$label $formatted_ip")
        tooltip_parts+=("$label: $ip ($interface)")
    fi
done

# Output JSON for waybar
if [ ${#output_parts[@]} -gt 0 ]; then
    # Join with pipe separator
    text=$(IFS=' | '; echo "${output_parts[*]}")
    # Join tooltip with literal \n for JSON newlines
    tooltip=""
    for i in "${!tooltip_parts[@]}"; do
        if [ $i -gt 0 ]; then
            tooltip+="\\n"
        fi
        tooltip+="${tooltip_parts[$i]}"
    done

    printf '{"text": "%s", "tooltip": "%s", "class": "connected"}\n' "$text" "$tooltip"
else
    printf '{"text": "No Network", "tooltip": "No active connections", "class": "disconnected"}\n'
fi

#!/bin/bash

# Define interfaces and their colors for the last octet
declare -A interfaces=(
    ["eno1"]="#50FA7B"    # Green
    ["wlan0"]="#FF5555"   # Red  
    ["wg0-mullvad"]="#FFB86C"  # Orange
)

# Function to get IP for an interface
get_interface_ip() {
    local interface=$1
    ip addr show "$interface" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1
}

# Function to format IP with colored last octet
format_ip() {
    local ip=$1
    local color=$2
    
    if [ -n "$ip" ]; then
        # Split IP into octets
        IFS='.' read -r -a octets <<< "$ip"
        
        # Format with colors: first three octets blue, last octet with interface color
        echo "%{F#5F6FFC}${octets[0]}.${octets[1]}.${octets[2]}.%{F-}%{F$color}${octets[3]}%{F-}"
    fi
}

# Build output string
output_parts=()

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
    fi
done

# Join output parts with separator
if [ ${#output_parts[@]} -gt 0 ]; then
    # Join with pipe separator
    IFS=' | '
    echo "${output_parts[*]}"
else
    echo ""
fi

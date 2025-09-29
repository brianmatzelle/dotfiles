#!/bin/bash

# Get WiFi info
interface="wlan0"
essid=$(iwgetid -r)
ip=$(ip route get 1.1.1.1 2>/dev/null | grep -Po '(?<=src )[\d.]+' | head -1)

if [ -n "$essid" ] && [ -n "$ip" ]; then
    # Split IP into octets
    IFS='.' read -r -a octets <<< "$ip"
    
    # Format with colors: first three octets blue, last octet red
    colored_ip="%{F#6272A4}${octets[0]}.${octets[1]}.${octets[2]}.%{F-}%{F#FF5555}${octets[3]}%{F-}"
    
    echo "$essid $colored_ip"
else
    echo ""
fi

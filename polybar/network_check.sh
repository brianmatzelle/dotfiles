#!/bin/bash

# Check ethernet first (priority)
ETH_INTERFACE="enp0s31f6"
WIFI_INTERFACE="wlan0"

# Check if ethernet is connected
if ip link show $ETH_INTERFACE 2>/dev/null | grep -q "state UP"; then
    # Ethernet is up, check if it has an IP
    ETH_IP=$(ip addr show $ETH_INTERFACE 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    if [[ -n "$ETH_IP" ]]; then
        echo "󰈀 $ETH_IP"
        exit 0
    fi
fi

# Check WiFi if ethernet is not connected
if ip link show $WIFI_INTERFACE 2>/dev/null | grep -q "state UP"; then
    # WiFi is up, get signal strength and SSID
    WIFI_SSID=$(iwgetid -r 2>/dev/null)
    if [[ -n "$WIFI_SSID" ]]; then
        # Get signal strength
        SIGNAL=$(grep $WIFI_INTERFACE /proc/net/wireless | awk '{ print int($3 * 100 / 70) }')
        
        # Choose icon based on signal strength
        if [[ $SIGNAL -ge 80 ]]; then
            ICON="󰤨"
        elif [[ $SIGNAL -ge 60 ]]; then
            ICON="󰤥"
        elif [[ $SIGNAL -ge 40 ]]; then
            ICON="󰤢"
        elif [[ $SIGNAL -ge 20 ]]; then
            ICON="󰤟"
        else
            ICON="󰤯"
        fi
        
        echo "$ICON $WIFI_SSID"
        exit 0
    fi
fi

# If neither is connected, show disconnected
echo "󰤭 Disconnected"

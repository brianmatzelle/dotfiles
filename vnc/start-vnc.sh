#!/bin/bash

# VNC startup script for i3 window manager using modern vncsession
# Sets up environment and starts VNC server

# Create TigerVNC config directory if it doesn't exist
mkdir -p /home/cowboy/.config/tigervnc

# Create TigerVNC config file with proper settings
cat > /home/cowboy/.config/tigervnc/config << EOF
session=i3
geometry=1920x1080
localhost=no
alwaysshared=1
dpi=96
EOF

# Set display environment
export DISPLAY=:1

# Kill any existing VNC session on display :1
pkill -f "vncsession.*cowboy.*:1" 2>/dev/null || true
pkill -f "Xvnc.*:1" 2>/dev/null || true

# Wait a moment for cleanup
sleep 2

# Start VNC session with vncsession (modern TigerVNC approach)
exec /usr/bin/vncsession cowboy :1
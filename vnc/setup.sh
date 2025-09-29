#!/bin/bash

# VNC Remote Desktop Setup Script
# Sets up VNC server with i3 window manager using modern TigerVNC

set -e

echo "Setting up VNC remote desktop with i3..."

# Create VNC directories (both old and new for compatibility)
mkdir -p ~/.vnc
mkdir -p ~/.config/tigervnc

# Copy configuration files
echo "Installing VNC configuration files..."
cp start-vnc.sh ~/.vnc/
cp xstartup ~/.vnc/
chmod +x ~/.vnc/start-vnc.sh
chmod +x ~/.vnc/xstartup

# Create VNC password if it doesn't exist
if [ ! -f ~/.vnc/passwd ]; then
    echo "Setting up VNC password..."
    read -s -p "Enter VNC password: " vnc_password
    echo
    echo "$vnc_password" | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
    # Copy to modern location as well
    cp ~/.vnc/passwd ~/.config/tigervnc/passwd
    chmod 600 ~/.config/tigervnc/passwd
    echo "✓ VNC password set"
else
    echo "✓ VNC password already exists"
    # Ensure it exists in modern location too
    cp ~/.vnc/passwd ~/.config/tigervnc/passwd 2>/dev/null || true
    chmod 600 ~/.config/tigervnc/passwd 2>/dev/null || true
fi

# Install systemd service
echo "Installing systemd service..."
sudo cp vnc-i3.service /etc/systemd/system/
sudo systemctl daemon-reload

echo ""
echo "✓ VNC setup complete!"
echo ""
echo "Next steps:"
echo "1. Enable service: sudo systemctl enable vnc-i3.service"
echo "2. Start service: sudo systemctl start vnc-i3.service"
echo "3. Connect locally: vncviewer localhost:1"
echo ""
echo "VNC will be available on port 5901 (display :1)"
echo "For remote access, use SSH tunneling: ssh -L 5901:localhost:5901 user@server"
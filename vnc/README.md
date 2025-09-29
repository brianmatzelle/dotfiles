# VNC Remote Desktop Package

VNC server setup for remote desktop access with i3 window manager.

## Quick Install

1. **Install TigerVNC:**
   ```bash
   sudo pacman -S tigervnc
   ```

2. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

3. **Set VNC password:**
   ```bash
   vncpasswd
   ```

4. **Enable and start the service:**
   ```bash
   sudo systemctl enable vnc-i3.service
   sudo systemctl start vnc-i3.service
   ```

## Access

- **Port:** 5901 (display :1)
- **Resolution:** 1920x1080
- **Security:** VNC authentication required

## Secure Access (Recommended)

Use SSH tunneling instead of direct VNC access:
```bash
ssh -L 5901:localhost:5901 user@server
```
Then connect VNC client to `localhost:5901`

## Files

- `vnc-i3.service` - Systemd service definition
- `start-vnc.sh` - VNC startup script
- `xstartup` - i3 session configuration
- `setup.sh` - Installation script
- `vnc-setup-commands.md` - Detailed manual setup instructions
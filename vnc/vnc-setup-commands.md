# VNC Service Setup - Manual Commands Required

## 1. Install TigerVNC
```bash
sudo pacman -S tigervnc
```

## 2. Install and enable the systemd service
```bash
sudo cp /home/cowboy/vnc-i3.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable vnc-i3.service
```

## 3. Set VNC password (run as user)
```bash
vncpasswd
```

## 4. Start the service
```bash
sudo systemctl start vnc-i3.service
```

## 5. Check service status
```bash
sudo systemctl status vnc-i3.service
```

## 6. View logs if needed
```bash
journalctl -u vnc-i3.service -f
```

## Network Access
- VNC will be available on port **5901** (display :1)
- For security, consider SSH tunneling:
  ```bash
  ssh -L 5901:localhost:5901 cowboy@your-server-ip
  ```
- Then connect VNC client to `localhost:5901`

## Firewall (if ufw is enabled)
```bash
sudo ufw allow 5901/tcp
```

## Files Created
- `/home/cowboy/vnc-i3.service` - Systemd service file
- `/home/cowboy/.vnc/start-vnc.sh` - VNC startup script
- `/home/cowboy/.vnc/xstartup` - i3 session configuration
- `/home/cowboy/.vnc/startup.log` - Service logs (created on first run)
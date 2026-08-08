# vpn-transfer

VPN manager for sing-box TUN on Linux (Niri/Sway/Wayland).

## Features
- `vpn-toggle` — on/off/toggle VPN
- `vpn-menu` — wofi server picker with ping
- `vpn-prescan` — ping all servers, sort by speed
- `vpn-recover` — restart TUN if down
- sing-box TUN mode with reality/xTLS support

## Configs included
- sing-box config example
- niri window manager
- foot terminal
- wofi launcher
- noctalia shell plugin
- udev rule for unprivileged TUN

## Usage
```bash
./bin/vpn-toggle on
./bin/vpn-menu
```

## Dependencies
- sing-box
- wofi
- python3
- systemd

# vpn-transfer

Sing-box TUN VPN manager with server picker for Linux (Wayland).

## Features

- **`vpn-toggle`** — on/off/toggle VPN + status
- **`vpn-menu`** — wofi picker with live ping
- **`vpn-prescan`** — ping all servers, sort by speed
- **`vpn-recover`** — auto-restart TUN if down
- **`sing-box-start`** — bootstrap sing-box with config

## Architecture

```
~/.local/share/vpn/servers.txt    → VLESS proxy list (reality + xtls)
~/.config/sing-box/config.json     → sing-box TUN config
~/.local/bin/vpn-*                 → symlinks to scripts
```

## Quick Start

1. Drop your VLESS proxies into `~/.local/share/vpn/servers.txt`
2. `sudo cp 99-singbox.conf /etc/sysctl.d/` (unprivileged TUN)
3. `./bin/sing-box-start`
4. `./bin/vpn-menu` — pick a server
5. `./bin/vpn-toggle on`

## Keybinds (Niri)

| Keys | Action |
|---|---|
| Mod+U | VPN menu |
| Mod+Alt+V | VPN toggle |

## Dependencies

- sing-box
- wofi
- python3

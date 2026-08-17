# vpn-transfer

Sing-box TUN VPN manager for Wayland (Niri/Sway). VLESS + Reality + xTLS.

> 📖 **Полный гайд по системе: архитектура, скрипты, поиск и проверка серверов, ChatGPT/Gemini-тесты** → **[VPN-GUIDE.md](VPN-GUIDE.md)**

## Features

| Command | Description |
|---|---|
| `vpn-toggle on/off/toggle` | Connect / disconnect |
| `vpn-toggle quick` | Reconnect to last server |
| `vpn-toggle save` | Save current server as default |
| `vpn-menu` | Wofi picker with ping bars + favorites |
| `vpn-prescan` | Fast TCP scan of all servers |
| `vpn-ping` | Latency probe → JSON cache |

## Architecture

```
~/.local/share/vpn/servers.txt     → VLESS proxy list
~/.config/sing-box/config.json     → sing-box TUN
~/.config/vpn/favorites.txt        → favorite servers
~/.config/vpn/last-server.txt      → last connected
/tmp/vpn-latency.json              → ping cache (auto-updated hourly)
/tmp/vpn-status                    → ON / OFF / CONNECTING
/tmp/vpn-prescan-cache.txt         → alive/dead cache
```

## Installation

```bash
# 1. Enable auto-ping
systemctl --user enable --now vpn-ping.timer

# 2. Allow unprivileged TUN
sudo cp 99-singbox.conf /etc/sysctl.d/

# 3. Drop your VLESS proxies
cp servers.txt ~/.local/share/vpn/
```

## Keybinds (Niri)

| Keys | Action |
|---|---|
| `Mod+U` | Server picker (wofi) |
| `Mod+Alt+V` | VPN toggle |

# VPN — полный гайд

> Документация по VPN-системе: как устроено, где что лежит, как искать серверы, как проверять.
> Протокол: **VLESS + Reality / TLS** через **sing-box** (TUN-режим). Работает на CachyOS + Niri/Sway (Wayland).

---

## 1. Как это устроено

```
Browser/приложения
      │
      ▼
  tun0 (TUN 172.19.0.2)          ← весь трафик системы уходит в sing-box
      │
      ▼
 sing-box  (~/.local/bin/sing-box)
      │  VLESS + Reality/TLS + xTLS-rprx-vision
      ▼
 VPN-сервер  (из ~/.local/share/vpn/servers.txt)
```

- **TUN-режим**: поднимается виртуальный интерфейс `tun0`, маршрут по умолчанию идёт через него. Никаких прокси-переменных — работает **весь** трафик (браузер, терминал, игры).
- **Протокол**: VLESS с `flow=xtls-rprx-vision`. Шифрование — Reality (с TLS-сертификатом реального сайта) либо обычный TLS.
- **Запуск**: `sing-box run -c ~/.config/sing-box/config.json` (через `sing-box-start`, поднимает ulimit).
- **Восстановление сети**: если что-то пошло не так — `vpn-recover` (сбрасывает маршруты, таблицы 2022, iptables, DNS).

---

## 2. Файлы и пути

| Путь | Что это |
|---|---|
| `~/.local/share/vpn/servers.txt` | **основной список** VLESS-конфигов (41 шт.) |
| `~/.config/sing-box/config.json` | рабочий конфиг sing-box (генерится на лету) |
| `~/.config/sing-box/config.example.json` | пример конфига |
| `~/.local/bin/sing-box` | сам бинарник sing-box |
| `~/.local/bin/sing-box-start` | запуск с ulimit + legacy DNS |
| `/tmp/vpn-status` | `ON` / `OFF` / `CONNECTING` |
| `/tmp/vpn-server-ip` | IP текущего сервера |
| `/tmp/vpn-server-name` | имя текущего сервера |
| `/tmp/vpn-prescan-cache.txt` | кэш проверки: `✓ 55ms [GPT] [GEM] имя` |
| `/tmp/vpn-gpt-cache.json` | результат ChatGPT-теста по каждому серверу |
| `/tmp/vpn-gemini-cache.json` | результат Gemini-теста по каждому серверу |
| `/tmp/vpn-latency.json` | латентность из prescan |
| `/tmp/vpn-menu-map.txt` | карта label→URL для wofi-меню |
| `/tmp/sing-box.log` | лог sing-box |

---

## 3. Скрипты

### `vpn-toggle` — подключение/отключение

| Команда | Действие |
|---|---|
| `vpn-toggle on` | подключить (сохранённый/последний сервер) |
| `vpn-toggle off` | отключить |
| `vpn-toggle toggle` | переключить |
| `vpn-toggle quick` | быстро переподключиться к последнему |
| `vpn-toggle save` | сохранить текущий как сервер по умолчанию |
| `vpn-toggle list` | показать список серверов |
| `vpn-toggle connect N` | подключиться к N-му серверу из списка |
| `vpn-toggle connect-url BASE64` | подключиться к произвольному конфигу |

Поднимает `tun0`, настраивает маршруты (таблица 2022, `0.0.0.0/1` + `128.0.0.0/1`), пишет статусы в `/tmp`.

### `vpn-menu` — выбор сервера (wofi)

Красивый picker с:

- флагом страны, чистым именем, пингом (цвет: зелёный <80мс, жёлтый <200мс, красный больше)
- маркерами `[GPT]` (работает ChatGPT) и `[GEM]` (работает Gemini)
- сортировкой по пингу, `▶` у текущего сервера, `✓/✗` живости
- строкой `■ OFF — отключить VPN` когда VPN включён

### `vpn-ping` — часовая проверка (systemd timer)

Для каждого сервера проверяет **3 вещи независимо**:

1. **RTT** — честный пинг: ICMP, при недоступности — TCP SYN-ACK. НЕ время полной цепочки.
2. **Handshake** — поднимает временный sing-box на порту `10820+i`, гоняет curl через socks5h до `icanhazip.com`. `✓` ставится **только если сервер реально проксирует трафик** (а не просто открыт порт).
3. **ChatGPT** — через `curl_cffi` (браузерный TLS-отпечаток Chrome 124). **Обычный curl на chatgpt.com всегда даёт ложный 403** (Cloudflare режет по отпечатку), поэтому нужен curl_cffi. `200` → `[GPT]`.
4. **Gemini** — страна exit-IP через `ip-api.com` (через тот же прокси). Страны из блок-листа (`RU, BY, CN, IR, KP, CU, SY, VE`) → `BLOCK`, остальные → `OK` → `[GEM]`. Gemini блокирует по гео клиентски — HTML одинаковый для всех стран, отличие только в exit-IP.

Пропускается, если VPN уже включён (результаты ненадёжны). Результаты пишет в `/tmp/vpn-prescan-cache.txt`.

### `vpn-prescan` — быстрый пред-скан (при загрузке)

Чистый ICMP-пинг всех серверов + запись `/tmp/vpn-latency.json`.

---

## 4. Формат сервера в servers.txt

```
vless://UUID@host:port?flow=xtls-rprx-vision&security=reality&sni=DOMAIN&fp=firefox&pbk=PUBKEY&sid=SHORTID#🇩🇪 Имя
```

- `security=reality` — Reality (нужен `pbk` + `sid`), иначе обычный `security=tls`.
- `sni` — серверное имя для TLS (у Reality это домен настоящего сайта).
- `fp` — отпечаток TLS клиента (`firefox`, `chrome`, `qq`...).
- `#имя` — URL-encoded имя (страна, провайдер).

---

## 5. Как искать серверы

### Источники конфигов

1. **Подписки-агрегаторы на GitHub**:
   - `morpheusadam/v2ray-config` — но без VLESS (ss/vmess)
   - `NiREvil/vless` — агрегатор, в README ссылки
   - `firefoxmmx2/v2rayshare_subcription` — base64, мало VLESS
   - `AvenCores/goida-vpn-configs` (форк `Romalakino/vpn-scraper`) — 25 файлов, обновление каждые 9 мин, но в основном мусор
2. **AetrisVPN Black list** (gitverse): `flaafix/AetrisVPN_Black_list` — 131 Reality, дал 13 рабочих с пингом <200мс. **Лучший источник.**
3. `shadowmere.xyz`, `proxypool.link`, `sub.amiralter.com`, `sub.irys.dpdns.org` — в основном trojan/ss, почти нет VLESS+Reality.

### Пайплайн поиска рабочих

```
Скачать подписки
  → оставить только vless:// + security=reality + flow=xtls-rprx-vision
  → дедуп по host:port
  → выкинуть уже имеющиеся
  → замерить RTT (ICMP/TCP), оставить < 200мс
  → TCP-alive фильтр (порт открыт)
  → VLESS-рукопожатие (временный sing-box + curl через socks)
  → только реально проксирующие = рабочие
```

**Важно**: публичные списки на 90%+ — мусор. Из 9834 VLESS+Reality из goida только 9 новых рабочих; из 1664 TCP-живых — тоже единицы. Рабочие дают в основном **AetrisVPN** и **core-multiplayer** (свои серверы).

---

## 6. Текущее состояние (проверено 2026-08)

- **Всего в списке**: 41 сервер
- **Живых (рукопожатие OK)**: ~32
- **ChatGPT OK** `[GPT]`: ~15
- **Gemini OK** `[GEM]`: ~31

### Лучшие по пингу

| Сервер | Страна | Пинг | GPT | GEM |
|---|---|---|---|---|
| `shop.core-multiplayer.com:3443` | 🇬🇧 | 14мс | ✅ | ✅ |
| `shop.core-multiplayer.com:443` | 🇷🇺 | 15мс | — | ❌ блок |
| `ai.core-multiplayer.com` | 🇬🇧 | 58мс | ✅ | ✅ |
| `gov.rkn.life` | 🇸🇪 | 45мс | ✅ | ✅ |
| `85.155.226.*` | 🇳🇱 | 55-60мс | ✅ | ✅ |
| `ai-3.core-multiplayer.com` | 🇩🇪 | 55мс | ✅ | ✅ |
| `spb.core-multiplayer.com:8443` | 🇩🇪 | 23мс | — | ✅ |

> ⚠️ `shop.core-multiplayer.com:443` — единственный сервер с **русским exit-IP** (Selectel). Gemini его блокирует (`BLOCK`), ChatGPT тоже может отвалиться. Для обхода зарубежных блокировок не использовать.

---

## 7. Автозапуск и systemd

```bash
# Часовая проверка серверов
systemctl --user enable --now vpn-ping.timer

# prescan при старте
# добавлен в автозапуск Niri (~/.config/niri/cfg/autostart.kdl)
```

- `vpn-ping.service` / `vpn-ping.timer` — часовая проверка → `/tmp/vpn-prescan-cache.txt`
- `fullscreen-watch` — подавление уведомлений в фуллскрине (не относится к VPN, но живёт рядом)

---

## 8. FAQ

**Почему обычный curl к chatgpt.com даёт 403?**
Cloudflare блокирует по TLS-отпечатку curl, а не по IP. Проверять ChatGPT надо через `curl_cffi` с `impersonate="chrome124"` (браузерный отпечаток). Тогда реальный код — 200.

**Почему Gemini блокирует даже с VPN?**
Gemini определяет страну по exit-IP клиента. Если VPN-сервер отдаёт русский IP (как `shop.core-multiplayer.com:443`), страница грузится, но показывает "не поддерживается в вашей стране". Проверка: страна exit-IP через geo-API.

**Почему пинг в меню — 55мс, а не 400мс?**
Раньше `vpn-ping` мерил время всей цепочки (запуск sing-box + рукопожатие + HTTP-поход). Теперь это отдельно: честный RTT (ICMP/TCP) + отдельный флаг живости.

**Как быстро добавить найденный сервер?**
Просто дописать строку `vless://...` в `~/.local/share/vpn/servers.txt` и запустить `vpn-ping` — он сам проверит и обновит кэш. Убедись что строка реально рабочая (рукопожатие).

---

## 9. Обновление списка из репо

```bash
# servers.txt живёт локально, в репо — копия для бэкапа/переноса
cp ~/.local/share/vpn/servers.txt ~/Проекты/vpn-transfer/config/sing-box/servers.example.txt
cd ~/Проекты/vpn-transfer
git add -A && git commit -m "servers: ..." && git push
```
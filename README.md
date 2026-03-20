# Scorebord — Live LED Wall Scoreboard

Real-time sports scoreboard for a 512×128 LED wall.
Control from **any device** (phone, tablet, laptop) via `https://scorebord.nextphase.be`.

```
[ Any phone / tablet / laptop ]
         anywhere
              │  wss:// (Cloudflare Tunnel)
              ▼
    [ Raspberry Pi — Node.js server :3000 ]
      Express + WebSocket + server-side clock
              │
         ws://localhost
              ▼
    [ Chromium kiosk ]──HDMI──[ LED Wall ]
       display.html
```

---

## Files

| File | Purpose |
|---|---|
| `server.js` | Node.js server — WebSocket, match state, server-side clock |
| `package.json` | Node.js dependencies |
| `public/controller.html` | Operator UI — open on any device |
| `public/display.html` | LED wall display — runs in Chromium kiosk on Pi |
| `setup.sh` | One-time Pi setup script |

---

## Pi setup (one time)

### 1. Flash Raspberry Pi OS
Flash **Raspberry Pi OS with Desktop** (64-bit) to the SD card using [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
In Imager settings, pre-configure:
- Username: `pi`
- WiFi credentials for the club network
- Enable SSH

### 2. Copy files to Pi
```bash
# On your laptop (SSH must be enabled):
scp -r . pi@<pi-ip>:~/scorebord
```

Or clone from GitHub:
```bash
ssh pi@<pi-ip>
git clone https://github.com/vervlietchristophe-bot/infobeamer-scoreboard.git scorebord
```

### 3. Run setup
```bash
ssh pi@<pi-ip>
sudo bash ~/scorebord/setup.sh
```

The Pi will reboot automatically. After reboot:
- The Node.js server starts automatically
- Chromium opens in kiosk mode showing the scoreboard display

---

## Cloudflare Tunnel setup (one time)

This gives you `https://scorebord.nextphase.be` accessible from anywhere.

### Step 1 — Add nextphase.be to Cloudflare
1. Create a free account at [cloudflare.com](https://cloudflare.com)
2. Click **Add a site** → enter `nextphase.be`
3. Choose the **Free** plan
4. Cloudflare will show you two nameservers (e.g. `ns1.cloudflare.com`)
5. In **GoDaddy**: go to DNS → Nameservers → change to Cloudflare's nameservers
6. Wait ~10 minutes for propagation

### Step 2 — Create the tunnel on the Pi
```bash
ssh pi@<pi-ip>

# Login (outputs a URL — open it on your laptop to authorize)
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create scoreboard

# Route the subdomain
cloudflared tunnel route dns scoreboard scorebord.nextphase.be

# Install as a system service (auto-starts on boot)
sudo cloudflared service install
sudo systemctl start cloudflared
```

### Step 3 — Done
Visit **https://scorebord.nextphase.be** from any device.

---

## Match day usage

| Who | Device | URL |
|---|---|---|
| Scorekeeper | Laptop / tablet | `https://scorebord.nextphase.be` |
| Referee | Phone | `https://scorebord.nextphase.be` |
| Display | Pi (auto) | `http://localhost:3000/display` |

1. Open the controller URL on your device
2. Set match format (2 halves or 4 quarters + duration)
3. Enter team names
4. Press **▶ Start** — clock runs on the server, all devices stay in sync
5. Use **+/−** buttons for goals

---

## Security (optional)

To password-protect the controller, enable **Cloudflare Access** (free):
1. In Cloudflare dashboard → Zero Trust → Access → Applications
2. Add application → `scorebord.nextphase.be`
3. Set an email-based or PIN-based policy
4. Only authorized users can access the controller

---

## Local access (same WiFi, no internet)
If the tunnel is down, the controller still works on the club's local network:
```
http://<pi-ip>:3000
```

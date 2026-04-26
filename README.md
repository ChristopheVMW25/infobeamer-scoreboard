# Scorebord — Live LED Wall Scoreboard

Real-time sports scoreboard for a 350×75 LED wall (4 panels: 100|75|75|100 wide × 75 tall).
Control from **any device** (phone, tablet, laptop) via `https://scorebord.nextphase.be`.

```
[ Any phone / tablet / laptop ]
         anywhere
              │  wss:// (Cloudflare Tunnel)
              ▼
    [ Windows NUC — Node.js server :3000 ]
      Express + WebSocket + server-side clock
              │
         ws://localhost
              ▼
    [ Chrome kiosk ]──HDMI──[ LED Wall ]
       display.html
```

---

## Files

| File | Purpose |
|---|---|
| `server.js` | Node.js server — WebSocket, match state, server-side clock |
| `package.json` | Node.js dependencies |
| `public/controller.html` | Operator UI — open on any device |
| `public/display.html` | LED wall display — runs in Chrome kiosk on the NUC |
| `start.bat` | Windows launcher — starts the server, then Chrome kiosk |
| `setup.sh` | Legacy Raspberry Pi setup script (not used on the NUC) |

---

## NUC setup (one time)

### 1. Install Node.js
Download the **LTS** installer from [nodejs.org](https://nodejs.org/) and run it. Accept all defaults.
Verify in a new Command Prompt:
```cmd
node -v
npm -v
```

### 2. Install Google Chrome
Download from [google.com/chrome](https://www.google.com/chrome/) if not already installed.
`start.bat` expects it at `C:\Program Files\Google\Chrome\Application\chrome.exe` — edit the path inside `start.bat` if yours differs.

### 3. Clone the repo and install dependencies
Open Command Prompt:
```cmd
cd D:\
git clone https://github.com/vervlietchristophe-bot/infobeamer-scoreboard.git Scorebord
cd Scorebord
npm install
```

### 4. Configure the LED-feeding display
- Right-click desktop → **Display settings**
- Select the screen wired to the LED controller
- Set **Display orientation** to match the LED's expected input (typically **Portrait** for this wall)
- Note the resolution shown — `display.html` auto-rotates and stretch-fills to whatever it finds

### 5. Test
Double-click `start.bat`. After ~2 seconds Chrome should open in kiosk mode showing the scoreboard. Press `Alt+F4` to close.

### 6. Auto-start on boot
- Win+R → `shell:startup` → an Explorer window opens
- Right-click `start.bat` → **Create shortcut** → drag the shortcut into the Startup folder
- Now `start.bat` runs automatically on every Windows login

For unattended operation, also configure Windows to **auto-login** (Win+R → `netplwiz` → uncheck "Users must enter a user name and password"), and disable sleep / screen lock under Settings → System → Power & battery.

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

### Step 2 — Create the tunnel on the NUC
Download `cloudflared` for Windows from the [Cloudflare releases page](https://github.com/cloudflare/cloudflared/releases) (`cloudflared-windows-amd64.exe`). Rename it to `cloudflared.exe` and place it somewhere on your `PATH` (e.g. `C:\Windows\System32\`).

Open Command Prompt **as Administrator**:
```cmd
REM Login (opens a browser tab — authorize the nextphase.be zone)
cloudflared tunnel login

REM Create tunnel
cloudflared tunnel create scoreboard

REM Route the subdomain
cloudflared tunnel route dns scoreboard scorebord.nextphase.be
```

Create `C:\Users\<you>\.cloudflared\config.yml`:
```yaml
tunnel: scoreboard
credentials-file: C:\Users\<you>\.cloudflared\<TUNNEL-UUID>.json

ingress:
  - hostname: scorebord.nextphase.be
    service: http://localhost:3000
  - service: http_status:404
```

Install as a Windows service (auto-starts on boot):
```cmd
cloudflared service install
```

### Step 3 — Done
Visit **https://scorebord.nextphase.be** from any device.

---

## Match day usage

| Who | Device | URL |
|---|---|---|
| Scorekeeper | Laptop / tablet | `https://scorebord.nextphase.be` |
| Referee | Phone | `https://scorebord.nextphase.be` |
| Display | NUC (auto) | `http://localhost:3000/display.html` |

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
http://<nuc-ip>:3000
```
Find the NUC's IP with `ipconfig` in Command Prompt.

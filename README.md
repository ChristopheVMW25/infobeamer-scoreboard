# Scorebord — Live LED Wall Scoreboard (laptop edition)

Real-time sports scoreboard for a 512×128 LED wall, running locally on a Windows laptop.
Laptop drives the LED wall over HDMI; referee controls the match from a phone over Wi-Fi.
                      +-----------------+
                      |   4G MiFi/modem |
                      |   (broadcasts   |
                      |     Wi-Fi)      |
                      +--------+--------+
                               |
                     Wi-Fi     |     Wi-Fi
                 +-------------+-------------+
                 |                           |
          +------+------+             +------+------+
          |   Laptop    |             |    Phone    |
          | Node server |   HTTP ->   | controller. |
          | display.html|             |    html     |
          +------+------+             +-------------+
                 |
               HDMI
                 |
          +------+------+
          |  LED Wall   |
          +-------------+
          
Everything runs on the laptop. No Pi, no cloud tunnel, no internet dependency beyond the 4G modem for phone ↔ laptop Wi-Fi.

---

## One-time setup on the laptop

1. Install **Node.js LTS** from https://nodejs.org (default options are fine).
2. Download this repository (green **Code** button → **Download ZIP**) and unzip somewhere easy, e.g. `C:\scorebord`.
3. Connect the laptop's HDMI output to the LED wall controller.
4. Connect the laptop to the 4G modem's Wi-Fi network.

That's it. You don't need a separate install step — `start.bat` handles `npm install` on first run.

---

## Match day

1. Make sure the laptop and the referee's phone are both on the **4G modem's Wi-Fi**.
2. Double-click **`start.bat`**.
   - Two browser tabs open: `display.html` and `controller.html`.
   - A black console window ("scoreboard-server") shows the LAN URL for the phone.
3. **Drag the display tab to the HDMI screen** and press **F11** for fullscreen.
4. **Controller on the laptop**: the second tab is ready to use.
5. **Controller on the phone**: on the phone browser, open the LAN URL printed in the server window, e.g. `http://192.168.8.101:3000/controller.html`. Bookmark it.
6. Use the controller to set team names, colours, format (halves/quarters + duration), then press ▶ Start.

When done, close the browser tabs and the server window (or press Ctrl+C in the server window).

---

## Files

| File | Purpose |
|---|---|
| `start.bat` | Double-click to launch the server + open browser tabs |
| `server.js` | Node.js server — WebSocket, match state, server-side clock |
| `package.json` | Node.js dependencies |
| `public/controller.html` | Operator UI — open on the laptop or on a phone |
| `public/display.html` | LED wall display — opened in a browser tab, dragged to HDMI |

---

## Troubleshooting

**The phone can't reach the controller URL.**
- Confirm the phone and laptop are both connected to the 4G modem's Wi-Fi.
- Check the URL printed in the server window — the laptop's IP may change if the modem was rebooted.
- Disable Windows Defender Firewall's "Public network" profile for Node.js, or set the 4G Wi-Fi profile to "Private" in Windows settings.

**Nothing shows up on the LED wall.**
- Is the display tab on the HDMI monitor, not the laptop's own screen? Drag it over.
- Press F11 to enter fullscreen.
- Some LED controllers expect a specific resolution from the HDMI — check the LED controller's manual.

**The clock drifts or jumps.**
- The clock runs on the server, not in the browser. If the server window was closed and re-opened, the clock resets. Keep the server window open the whole match.

**`start.bat` says "Node.js is not installed".**
- Install Node.js LTS from https://nodejs.org and double-click `start.bat` again.

---

## Local access without the 4G modem

If the 4G modem dies mid-match, you can still run the match from the laptop itself — the controller tab is already open on the laptop. The phone just won't be able to connect until Wi-Fi is back.

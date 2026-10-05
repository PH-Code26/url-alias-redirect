# URL Alias Redirect Service

> Type `mygit` in your browser → lands on `https://github.com`. No plugins. No typing full URLs. Just works.

A zero-dependency Windows local redirect service that maps short aliases to any URL. Like a personal DNS shortcut system, but simpler.

## ✨ Why This?

You probably type the same URLs dozens of times a day:

```
google.com         → 5 seconds
github.com         → 5 seconds
mail.google.com    → 7 seconds
```

With aliases: `gg` `gh` `gm` → **under 1 second each**. Save ~30 minutes a year.

| Without This | With This |
|-------------|-----------|
| Type full URL | Type `mygit` |
| `Ctrl+L`, type, `Enter` | Type alias, `Enter` |
| Remember exact domains | Remember short names |

## 🚀 How It Works

```
Browser: mygit
    ↓
Windows hosts resolves to 127.0.0.2
    ↓
Port forwarding 80→5666 / 443→5667
    ↓
Node.js server matches aliases.json
    ↓
HTTP 302 redirect → https://github.com
```

## 📦 Features

- **URL alias mapping** — `mysite` → `https://example.com`
- **HTTP + HTTPS** — ports `5666` / `5667`
- **Auto SSL certificate generation** — self-signed, works on localhost
- **Transparent port forwarding** — 80→5666, 443→5667. No port numbers in your URLs
- **Auto-start on login** — runs silently in background
- **One-click uninstall** — clean removal of all hosts entries, port forwards, and scheduled tasks
- **Zero npm dependencies** — uses only Node.js built-in `http`, `https`, `fs`, `path`

## ⚡ Quick Start

### 1. Configure aliases

Edit `aliases.json`:

```json
{
  "mygit": "https://github.com",
  "mywiki": "https://wikipedia.org",
  "mymail": "https://mail.google.com"
}
```

### 2. One-click install

Right-click `setup.bat` → **Run as Administrator**.

That's it. It will:
- Generate SSL certificate (`cert.pfx`)
- Write aliases to Windows hosts file (`127.0.0.2`)
- Set up port forwarding (80→5666)
- Register auto-start scheduled task
- Launch the service

### 3. Verify

Visit `https://localhost:5667`, accept the self-signed cert warning, then type any alias directly in your address bar.

## 📁 File Overview

| File | Purpose |
|------|---------|
| `server.js` | Core redirect server (HTTP + HTTPS) |
| `aliases.json` | Alias configuration |
| `setup.bat` | One-click setup (requires Admin) |
| `cleanup.bat` | One-click uninstall (requires Admin) |
| `start.bat` | Foreground launch (with terminal window) |
| `start-silent.vbs` | Background launch (used by auto-start) |
| `restart.bat` | Restart the service |
| `https-on.bat` | Enable 443→5667 port forwarding |
| `https-off.bat` | Disable 443 port forwarding |
| `generate-cert.ps1` | Generate self-signed SSL certificate |

## 🔧 Requirements

- Windows 10 / 11
- Node.js (any recent version)
- Administrator privileges (for setup only)

## 🗑️ Uninstall

Right-click `cleanup.bat` → **Run as Administrator**. Removes all traces.

## 🧱 Tech Stack

- Node.js built-in modules (no `npm install` needed)
- Windows `hosts` file + `netsh portproxy`
- Self-signed PFX certificate (PowerShell)
- VBScript for silent background startup

## ⚠️ Notes

- Browsers will show a certificate warning on first HTTPS visit — click "Proceed" to trust the self-signed cert.
- Edit `aliases.json` and run `restart.bat` to apply changes.
- For production/public use, replace `cert.pfx` with a real CA-signed certificate.

## 📄 License

MIT
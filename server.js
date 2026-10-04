const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const HTTP_PORT = process.env.HTTP_PORT || 5666;
const HTTPS_PORT = process.env.HTTPS_PORT || 5667;
const ALIASES_FILE = path.join(__dirname, 'aliases.json');
const CERT_FILE = path.join(__dirname, 'cert.pfx');
const CERT_PASS = 'alias123';

function loadAliases() {
  const raw = fs.readFileSync(ALIASES_FILE, 'utf-8');
  return JSON.parse(raw);
}

function getTarget(host) {
  const aliases = loadAliases();
  const name = host.split(':')[0].toLowerCase();
  return aliases[name] || null;
}

function handleRequest(req, res) {
  const host = req.headers.host || '';
  const target = getTarget(host);

  if (target) {
    res.writeHead(302, { Location: target });
    res.end();
  } else {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    const aliases = loadAliases();
    const aliasRows = Object.entries(aliases)
      .map(([k, v]) => `<li><code>${k}</code> &rarr; <a href="${v}">${v}</a></li>`)
      .join('');
    res.end(`<!DOCTYPE html><html lang="zh-CN">
<head><meta charset="UTF-8"><title>Redirect Service</title>
<style>
body{font-family:'Microsoft YaHei',sans-serif;max-width:600px;margin:80px auto;padding:20px;background:#1e1e2e;color:#cdd6f4}
h1{color:#cba6f7}a{color:#89b4fa}code{background:#313244;padding:2px 6px;border-radius:4px}li{margin:8px 0}
</style></head><body>
<h1>Redirect Service Running</h1>
<p>Alias <code>${host}</code> not configured.</p>
<p>Configured aliases:</p><ul>${aliasRows}</ul>
<p style="color:#6c7086;font-size:12px">Edit aliases.json to add more</p>
</body></html>`);
  }
}

const httpServer = http.createServer(handleRequest);
httpServer.listen(HTTP_PORT, () => {
  console.log(`HTTP  → http://localhost:${HTTP_PORT}`);
});

if (fs.existsSync(CERT_FILE)) {
  const pfx = fs.readFileSync(CERT_FILE);
  const httpsServer = https.createServer({ pfx, passphrase: CERT_PASS }, handleRequest);
  httpsServer.listen(HTTPS_PORT, () => {
    console.log(`HTTPS → https://localhost:${HTTPS_PORT}`);
    console.log('');
    const aliases = loadAliases();
    console.log('Aliases:');
    Object.entries(aliases).forEach(([k, v]) => {
      console.log(`  ${k}  →  ${v}`);
    });
    console.log('');
    console.log('First visit: accept the self-signed cert warning in browser.');
    console.log('Then type alias directly (no / needed).');
    console.log('');
    console.log('Press Ctrl+C to stop');
  });
} else {
  console.log('No cert.pfx found, HTTPS disabled.');
  console.log('Run: powershell -File generate-cert.ps1');
  console.log('');
  const aliases = loadAliases();
  console.log('Aliases:');
  Object.entries(aliases).forEach(([k, v]) => {
    console.log(`  ${k}  →  ${v}`);
  });
  console.log('');
  console.log('Press Ctrl+C to stop');
}
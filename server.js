const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const HTTP_PORT = process.env.HTTP_PORT || 5666;
const HTTPS_PORT = process.env.HTTPS_PORT || 5667;
const ALIASES_FILE = path.join(__dirname, 'aliases.json');
const CERT_FILE = path.join(__dirname, 'cert.pfx');
const CERT_PASS = 'alias123';

let aliasesCache = null;

function loadAliases() {
  let raw;
  try {
    raw = fs.readFileSync(ALIASES_FILE, 'utf-8');
  } catch (_) {
    return {};
  }
  try {
    return JSON.parse(raw);
  } catch (_) {
    return {};
  }
}

function getAliasesFromCache() {
  if (aliasesCache === null) {
    aliasesCache = loadAliases();
    fs.watch(ALIASES_FILE, () => {
      aliasesCache = null;
    });
  }
  return aliasesCache;
}

function getTarget(hostname) {
  const aliases = getAliasesFromCache();
  const name = hostname.split(':')[0].toLowerCase();
  return aliases[name] || null;
}

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function handleRequest(req, res) {
  const host = req.headers.host || '';
  const target = getTarget(host);

  if (target) {
    const safeTarget = encodeURI(target);
    try {
      res.writeHead(302, { Location: safeTarget });
    } catch (_) {
      res.writeHead(302, { Location: '/' });
    }
    res.end();
  } else {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    const aliases = getAliasesFromCache();
    const aliasRows = Object.entries(aliases)
      .map(([k, v]) => `<li><code>${escapeHtml(k)}</code> &rarr; <a href="${escapeHtml(v)}">${escapeHtml(v)}</a></li>`)
      .join('');
    res.end(`<!DOCTYPE html><html lang="zh-CN">
<head><meta charset="UTF-8"><title>Redirect Service</title>
<style>
body{font-family:'Microsoft YaHei',sans-serif;max-width:600px;margin:80px auto;padding:20px;background:#1e1e2e;color:#cdd6f4}
h1{color:#cba6f7}a{color:#89b4fa}code{background:#313244;padding:2px 6px;border-radius:4px}li{margin:8px 0}
</style></head><body>
<h1>Redirect Service Running</h1>
<p>Alias <code>${escapeHtml(host)}</code> not configured.</p>
<p>Configured aliases:</p><ul>${aliasRows}</ul>
<p style="color:#6c7086;font-size:12px">Edit aliases.json to add more</p>
</body></html>`);
  }
}

const httpServer = http.createServer(handleRequest);
httpServer.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.log(`Service already running on port ${HTTP_PORT}.`);
    process.exit(0);
  } else {
    console.error(err);
    process.exit(1);
  }
});
httpServer.listen(HTTP_PORT, () => {
  console.log(`HTTP  → http://localhost:${HTTP_PORT}`);
});

function printAliases() {
  const aliases = getAliasesFromCache();
  console.log('Aliases:');
  Object.entries(aliases).forEach(([k, v]) => {
    console.log(`  ${k}  →  ${v}`);
  });
}

if (fs.existsSync(CERT_FILE)) {
  const pfx = fs.readFileSync(CERT_FILE);
  const httpsServer = https.createServer({ pfx, passphrase: CERT_PASS }, handleRequest);
  httpsServer.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.log(`Service already running on port ${HTTPS_PORT}.`);
      process.exit(0);
    } else {
      console.error(err);
      process.exit(1);
    }
  });
  httpsServer.listen(HTTPS_PORT, () => {
    console.log(`HTTPS → https://localhost:${HTTPS_PORT}`);
    console.log('');
    printAliases();
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
  printAliases();
  console.log('');
  console.log('Press Ctrl+C to stop');
}
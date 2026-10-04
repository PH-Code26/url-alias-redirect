# URL Alias Redirect Service

一个 Windows 本地 URL 别名重定向服务，让你在浏览器地址栏输入自定义短名称即可跳转到目标网址。

## 功能特性

- **URL 别名映射** — 在浏览器输入 `mysite` 自动跳转到 `https://example.com`
- **HTTP + HTTPS 双协议** — HTTP 端口 `5666`，HTTPS 端口 `5667`
- **自动生成 SSL 证书** — 一键生成自签名证书，支持 HTTPS
- **端口转发** — 自动将 80→5666、443→5667，无需手动输入端口号
- **开机自启** — 登录 Windows 后自动在后台静默运行
- **一键卸载** — 完整清理 hosts、端口转发、计划任务

## 快速开始

### 1. 配置别名

编辑 `aliases.json`，添加你的别名映射：

```json
{
  "mygit": "https://github.com",
  "mywiki": "https://wikipedia.org",
  "mymail": "https://mail.google.com"
}
```

### 2. 一键安装

右键 `setup.bat` → **以管理员身份运行**。

安装脚本会自动完成：
- 生成 SSL 证书（cert.pfx）
- 将别名写入系统 hosts 文件（127.0.0.2）
- 配置 80→5666 端口转发
- 注册开机自启任务
- 启动服务

### 3. 验证

浏览器访问 `https://localhost:5667`，接受自签名证书警告后即可使用。

直接在地址栏输入别名（如 `mygit`）即可跳转。

## 脚本说明

| 文件 | 说明 |
|------|------|
| `server.js` | Node.js 服务端核心（HTTP/HTTPS 重定向） |
| `aliases.json` | 别名配置文件 |
| `setup.bat` | 一键安装脚本（需管理员权限） |
| `cleanup.bat` | 一键卸载脚本（需管理员权限） |
| `start.bat` | 前台启动服务（带终端窗口） |
| `start-silent.vbs` | 后台静默启动（开机自启调用） |
| `restart.bat` | 重启服务 |
| `https-on.bat` | 开启 443→5667 端口转发 |
| `https-off.bat` | 关闭 443 端口转发 |
| `generate-cert.ps1` | 生成自签名 SSL 证书 |

## 工作原理

```
浏览器输入别名 (mysite)
    ↓
Windows hosts 解析 → 127.0.0.2
    ↓
端口转发 80→5666 / 443→5667
    ↓
Node.js Server 匹配 aliases.json
    ↓
HTTP 302 重定向到目标 URL
```

## 技术栈

- Node.js (http/https 内置模块)
- Windows hosts / netsh portproxy
- 自签名 PFX 证书
- VBScript 后台启动

## 卸载

右键 `cleanup.bat` → **以管理员身份运行**，即可清理所有配置。

## 许可证

MIT
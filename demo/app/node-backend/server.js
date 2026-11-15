'use strict';

// 只用 Node 内置模块，无第三方依赖：npm install 不会真的下载任何东西，
// 保留依赖安装步骤是为了让示例能直接换成 express/koa 等框架。
const http = require('node:http');
const os = require('node:os');
const process = require('node:process');

// 国内时区 UTC+8，容器内 TZ 即使没生效也能输出正确时间
const TZ8 = 8 * 60 * 60 * 1000;
const START = Date.now();

const TZ_FMT = new Intl.DateTimeFormat('sv-SE', {
  timeZone: 'Asia/Shanghai',
  year: 'numeric', month: '2-digit', day: '2-digit',
  hour: '2-digit', minute: '2-digit', second: '2-digit',
});

function now() {
  // sv-SE 输出 2026-11-15 10:00:00，再补 +08:00
  return `${TZ_FMT.format(new Date())} +08:00`;
}

function info() {
  return {
    message: 'node demo is running',
    node: process.version,
    deps: 'none (node builtins only)',
    os: `${os.platform()}/${os.arch()}`,
    hostname: os.hostname(),
    time: now(),
    uptime: `${Math.floor((Date.now() - START) / 1000)}s`,
  };
}

function sendJSON(res, code, body) {
  const data = JSON.stringify(body);
  res.writeHead(code, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(data);
}

function page() {
  const i = info();
  const rows = Object.entries(i)
    .map(([k, v]) => `<tr><th>${k}</th><td>${escapeHtml(String(v))}</td></tr>`)
    .join('\n');
  return `<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>node demo</title>
<style>body{font-family:-apple-system,"PingFang SC",sans-serif;margin:40px;color:#222}
table{border-collapse:collapse}th,td{border:1px solid #ddd;padding:6px 12px;text-align:left}th{background:#f5f5f5}</style>
</head>
<body>
<h1>node demo 运行信息</h1>
<table>
${rows}
</table>
<p>其他接口：<code>/health</code>、<code>/api/hello?name=x</code></p>
</body>
</html>`;
}

function escapeHtml(s) {
  return s.replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);

  if (req.method !== 'GET' && req.method !== 'HEAD') {
    res.writeHead(405, { Allow: 'GET, HEAD' });
    res.end('method not allowed');
    return;
  }

  switch (url.pathname) {
    case '/':
    case '/api/info':
      sendJSON(res, 200, info());
      return;
    case '/health':
      res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('ok');
      return;
    case '/api/hello':
      sendJSON(res, 200, {
        message: `Hello, ${url.searchParams.get('name') || 'demo'}!`,
        time: now(),
      });
      return;
    case '/page':
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(page());
      return;
    default:
      sendJSON(res, 404, { error: 'not found', path: url.pathname });
  }
});

const port = Number(process.env.APP_PORT || 8087);
const host = '0.0.0.0';

// SIGTERM 时先停止接收新连接，再等已有请求结束；docker stop 会发 SIGTERM
server.listen(port, host, () => {
  console.log(`node demo listening on http://${host}:${port} (node ${process.version})`);
});

for (const sig of ['SIGTERM', 'SIGINT']) {
  process.on(sig, () => {
    console.log(`${sig} received, closing server`);
    server.close(() => process.exit(0));
    // 兜底：10 秒还没关干净就强制退出
    setTimeout(() => process.exit(1), 10000).unref();
  });
}

// TZ8 仅用于注释说明时区，避免 lint 报未使用
void TZ8;

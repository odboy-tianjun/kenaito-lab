//! Rust 简单 Web 示例：只用标准库 `TcpListener` 手写 HTTP/1.1，无第三方依赖。
//!
//! 这样示例的构建不依赖 crates.io，离线也能编译；换成 axum/actix-web 只需替换
//! `handle` 与 `Cargo.toml` 的依赖，Dockerfile 与部署方式不用改。

use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::Arc;
use std::thread;
use std::time::{Instant, SystemTime, UNIX_EPOCH};

/// 国内时区 UTC+8，容器内 TZ 即使没生效也能输出正确时间
const TZ_OFFSET_SECS: u64 = 8 * 3600;

struct App {
    started: Instant,
}

impl App {
    fn info(&self) -> String {
        format!(
            "{{\"message\":\"rust demo is running\",\"rust\":\"{}\",\"os\":\"{}\",\"hostname\":\"{}\",\"zoneId\":\"+08:00\",\"time\":\"{}\",\"uptime\":\"{}s\"}}",
            env!("CARGO_PKG_VERSION"),
            std::env::consts::OS,
            hostname(),
            now_tz8(),
            self.started.elapsed().as_secs(),
        )
    }
}

fn main() {
    let port = std::env::var("APP_PORT").unwrap_or_else(|_| "8088".to_string());
    let addr = format!("0.0.0.0:{port}");
    let listener = TcpListener::bind(&addr).unwrap_or_else(|e| {
        eprintln!("rust demo: bind {addr} failed: {e}");
        std::process::exit(1);
    });
    println!("rust demo listening on http://{addr}");

    let app = Arc::new(App {
        started: Instant::now(),
    });
    for stream in listener.incoming() {
        let stream = match stream {
            Ok(s) => s,
            Err(e) => {
                eprintln!("rust demo: accept failed: {e}");
                continue;
            }
        };
        // 每个连接一个线程：示例规模够用；生产建议用 tokio/axum。
        // App 用 Arc 共享，clone 出的 Arc 是 'static 的，可以直接 move 进线程。
        let app = Arc::clone(&app);
        thread::spawn(move || handle(stream, &app));
    }
}

fn handle(mut stream: TcpStream, app: &App) {
    let mut buf = [0u8; 2048];
    let n = match stream.read(&mut buf) {
        Ok(n) if n > 0 => n,
        _ => return,
    };
    let req = String::from_utf8_lossy(&buf[..n]);
    let mut parts = req.lines().next().unwrap_or("").split_whitespace();
    let method = parts.next().unwrap_or("");
    let target = parts.next().unwrap_or("/");
    let path = target.split('?').next().unwrap_or("/");
    let query = target.split_once('?').map(|(_, q)| q).unwrap_or("");

    let (code, ctype, body) = match (method, path) {
        ("GET" | "HEAD", "/" | "/api/info") => (200, "application/json; charset=utf-8", app.info()),
        ("GET" | "HEAD", "/health") => (200, "text/plain; charset=utf-8", "ok\n".to_string()),
        ("GET" | "HEAD", "/api/hello") => {
            let name = query_value(query, "name").unwrap_or_else(|| "demo".to_string());
            (
                200,
                "application/json; charset=utf-8",
                format!(
                    "{{\"message\":\"Hello, {}!\",\"time\":\"{}\"}}",
                    json_escape(&name),
                    now_tz8()
                ),
            )
        }
        ("GET" | "HEAD", "/page") => (200, "text/html; charset=utf-8", page(app)),
        ("GET" | "HEAD", _) => (
            404,
            "application/json; charset=utf-8",
            "{\"error\":\"not found\"}".to_string(),
        ),
        _ => (405, "text/plain; charset=utf-8", "method not allowed".to_string()),
    };

    let head_only = method == "HEAD";
    let body = if head_only { String::new() } else { body };
    let resp = format!(
        "HTTP/1.1 {code} {reason}\r\nContent-Type: {ctype}\r\nContent-Length: {len}\r\nConnection: close\r\n\r\n{body}",
        reason = status_reason(code),
        len = body.len(),
    );
    let _ = stream.write_all(resp.as_bytes());
    let _ = stream.flush();
}

fn status_reason(code: u16) -> &'static str {
    match code {
        200 => "OK",
        404 => "Not Found",
        405 => "Method Not Allowed",
        _ => "Unknown",
    }
}

fn page(app: &App) -> String {
    let info = app.info();
    format!(
        "<!DOCTYPE html>\n<html lang=\"zh-CN\">\n<head><meta charset=\"UTF-8\"><title>rust demo</title>\n\
<style>body{{font-family:-apple-system,\"PingFang SC\",sans-serif;margin:40px;color:#222}}\
table{{border-collapse:collapse}}th,td{{border:1px solid #ddd;padding:6px 12px;text-align:left}}\
th{{background:#f5f5f5}}</style>\n</head>\n<body>\n<h1>rust demo 运行信息</h1>\n\
<pre>{info}</pre>\n<p>其他接口：<code>/health</code>、<code>/api/hello?name=x</code></p>\n</body>\n</html>\n"
    )
}

fn query_value(query: &str, key: &str) -> Option<String> {
    query.split('&').find_map(|kv| {
        let (k, v) = kv.split_once('=')?;
        if k == key {
            Some(
                v.replace('+', " ")
                    .replace("%20", " "),
            )
        } else {
            None
        }
    })
}

fn json_escape(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\\"")
}

fn hostname() -> String {
    std::fs::read_to_string("/etc/hostname")
        .map(|s| s.trim().to_string())
        .unwrap_or_else(|_| "unknown".to_string())
}

/// 输出 `YYYY-MM-DD HH:MM:SS +08:00`，只用标准库推算，不引 chrono
fn now_tz8() -> String {
    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0)
        + TZ_OFFSET_SECS;
    let (y, m, d) = civil_from_days((secs / 86400) as i64);
    let rem = secs % 86400;
    format!(
        "{y:04}-{m:02}-{d:02} {:02}:{:02}:{:02} +08:00",
        rem / 3600,
        (rem % 3600) / 60,
        rem % 60
    )
}

/// 天数（自 1970-01-01）转公历年月日，Howard Hinnant 的 civil_from_days 算法
fn civil_from_days(z: i64) -> (i64, u32, u32) {
    let z = z + 719468;
    let era = if z >= 0 { z } else { z - 146096 } / 146097;
    let doe = (z - era * 146097) as u64;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let y = yoe as i64 + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = (doy - (153 * mp + 2) / 5 + 1) as u32;
    let m = if mp < 10 { mp + 3 } else { mp - 9 } as u32;
    (if m <= 2 { y + 1 } else { y }, m, d)
}

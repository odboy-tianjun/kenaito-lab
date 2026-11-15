package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"
)

// 国内时区 UTC+8，容器内 TZ 即使没生效也能输出正确时间
var tz8 = time.FixedZone("CST", 8*3600)

var startTime = time.Now()

func main() {
	http.HandleFunc("/", withMethod(info))
	http.HandleFunc("/health", withMethod(health))
	http.HandleFunc("/api/hello", withMethod(hello))
	http.HandleFunc("/page", withMethod(page))

	port := env("APP_PORT", "8086")
	addr := ":" + port
	log.Printf("go demo listening on %s (go %s)", addr, runtime.Version())
	// 只注册 GET 路由，其余请求由 default mux 返回 404
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("listen failed: %v", err)
	}
}

// withMethod 只放行 GET/HEAD，避免被当作任意方法都能调用的演示
func withMethod(h func(w http.ResponseWriter, r *http.Request)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet && r.Method != http.MethodHead {
			w.Header().Set("Allow", "GET, HEAD")
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		h(w, r)
	}
}

func info(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	writeJSON(w, map[string]any{
		"message":  "go demo is running",
		"go":       runtime.Version(),
		"os":       runtime.GOOS + "/" + runtime.GOARCH,
		"hostname": hostname(),
		"zoneId":   time.Now().In(tz8).Format("-07:00"),
		"time":     time.Now().In(tz8).Format("2006-01-02 15:04:05 -07:00"),
		"uptime":   time.Since(startTime).Truncate(time.Second).String(),
	})
}

func health(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	fmt.Fprintln(w, "ok")
}

func hello(w http.ResponseWriter, r *http.Request) {
	name := r.URL.Query().Get("name")
	if name == "" {
		name = "demo"
	}
	writeJSON(w, map[string]any{
		"message": "Hello, " + name + "!",
		"time":    time.Now().In(tz8).Format("2006-01-02 15:04:05 -07:00"),
	})
}

// page 返回一个简单的 HTML 页面；模板在编译期以常量嵌入二进制，运行时不需要额外文件
func page(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	fmt.Fprintf(w, pageHTML, runtime.Version(), hostname(),
		time.Now().In(tz8).Format("2006-01-02 15:04:05 -07:00"))
}

const pageHTML = `<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><title>go demo</title>
<style>body{font-family:-apple-system,"PingFang SC",sans-serif;margin:40px;color:#222}
table{border-collapse:collapse}th,td{border:1px solid #ddd;padding:6px 12px;text-align:left}th{background:#f5f5f5}</style>
</head>
<body>
<h1>go demo 运行信息</h1>
<table>
<tr><th>go</th><td>%s</td></tr>
<tr><th>hostname</th><td>%s</td></tr>
<tr><th>time</th><td>%s</td></tr>
</table>
<p>其他接口：<code>/health</code>、<code>/api/hello?name=x</code></p>
</body>
</html>
`

func writeJSON(w http.ResponseWriter, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if err := json.NewEncoder(w).Encode(v); err != nil {
		log.Printf("encode json failed: %v", err)
	}
}

func hostname() string {
	if h, err := os.Hostname(); err == nil {
		return h
	}
	return "unknown"
}

func env(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

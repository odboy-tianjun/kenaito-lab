# go 示例

演示如何用 `compile-go123` + `runtime-go123` 两阶段构建一个 Go 1.23 Web 服务。只用标准库，无第三方依赖（不需要 `go.sum`）。

| 阶段 | 镜像 | 说明 |
| --- | --- | --- |
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-go123` | Go + `GOPROXY=goproxy.cn`，常见 Makefile / cgo 工具链 |
| 运行 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-go123` | 仅 Go 运行时 |

### 示例内容

```
go/
├── go.mod              # module demo, go 1.22（1.23 镜像可直接编译）
├── main.go             # 标准库 net/http：/、/health、/api/hello、/page
├── Dockerfile          # 两阶段：compile-go123 -> runtime-go123
├── build.sh            # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml  # 部署编排（端口 8086，固定 IP 172.31.0.20）
├── startup.sh          # docker-compose up -d
└── shutdown.sh         # docker-compose down
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-go .
PUSH=1 sh build.sh     # 构建并推送
sh startup.sh          # docker-compose -f docker-compose.yml -p go-demo up -d
```

访问：

```shell
curl http://127.0.0.1:8086/                    # {"message":"go demo is running","go":"go1.23.12",...}
curl http://127.0.0.1:8086/health              # ok
curl http://127.0.0.1:8086/api/hello?name=demo # {"message":"Hello, demo!",...}
```

浏览器打开 http://127.0.0.1:8086/page 可看到 HTML 页面。

### 关键点

**静态编译**：`CGO_ENABLED=0 go build -trimpath -ldflags="-s -w"`。产物是静态二进制，运行镜像里不需要 glibc 之外的任何东西；
`-trimpath` 去掉本机绝对路径，`-s -w` 去掉符号表与调试信息，镜像更小。

**依赖层缓存**：先 `COPY go.mod` 执行 `go mod download`，再 `COPY *.go` 编译；本示例无依赖，换成有依赖的项目时这一步才有意义。

**端口**：容器内 8086（`APP_PORT`），避开前面示例占用的 8080-8085。

**模板内嵌**：`/page` 的 HTML 以常量写进二进制，运行时不需要额外拷贝文件——这也是 Go 镜像可以只带一个二进制的原因。

### 停止

```shell
sh shutdown.sh
```

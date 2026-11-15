# rust 示例

演示如何用 `compile-rust` + `runtime-rust` 两阶段构建一个 Rust 1.100 Web 服务。只用标准库 `TcpListener` 手写 HTTP/1.1，
无第三方 crate，因此示例构建不依赖 crates.io，离线也能编译。

| 阶段 | 镜像 | 说明 |
| --- | --- | --- |
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-rust` | rustc/cargo + gcc/make，crates 源走阿里云镜像 |
| 运行 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-rust` | rustc/cargo 运行时；示例只跑二进制，不需要工具链 |

### 示例内容

```
rust/
├── Cargo.toml          # edition 2021，无依赖；release 开 LTO / strip / panic=abort 减小体积
├── src/main.rs         # 标准库 TcpListener：/、/api/info、/health、/api/hello、/page
├── Dockerfile          # 两阶段：compile-rust -> runtime-rust
├── build.sh            # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml  # 部署编排（端口 8088，固定 IP 172.31.2.20）
├── startup.sh          # docker-compose up -d
└── shutdown.sh         # docker-compose down
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-rust .
PUSH=1 sh build.sh     # 构建并推送
sh startup.sh          # docker-compose -f docker-compose.yml -p rust-demo up -d
```

访问：

```shell
curl http://127.0.0.1:8088/                # {"message":"rust demo is running",...}
curl http://127.0.0.1:8088/health          # ok
curl http://127.0.0.1:8088/api/hello?name=demo
```

浏览器打开 http://127.0.0.1:8088/page 可看到 HTML 页面。

### 关键点

**无第三方依赖**：示例只用了 `std`，构建时不需要访问 crates.io。要用 axum / actix-web 时，
在 `Cargo.toml` 加依赖即可，`compile-rust` 里已经把 crates 源换成阿里云稀疏索引，Dockerfile 不用改。

**依赖层缓存**：先 `COPY Cargo.toml` 并用一个空 `main.rs` 跑一次 `cargo build --release`，
再 `COPY src` 正式编译；只有 `Cargo.toml` 变化时才会重新编译依赖。

桩产物放在 `--target-dir /tmp/deps-target`，不落到 `/src/target`，避免正式编译看到“产物比源码新”
而跳过重编、把桩程序拷进运行镜像；运行阶段还会 `grep` 二进制里的启动日志做构建期自检。

**时间换算不引 chrono**：标准库里没有日期格式化，示例用 Howard Hinnant 的 `civil_from_days` 算法把 UTC 秒数
换成 `YYYY-MM-DD HH:MM:SS +08:00`，保持零依赖。

**线程模型**：`App` 用 `Arc` 共享，每个连接 `Arc::clone` 后 `thread::spawn`，只适合示例；生产用 tokio/axum 异步处理。

**停止**：`ENTRYPOINT ["/home/admin/rust-demo"]` 为 exec 形式，SIGTERM 可直接终止进程，无额外清理逻辑。

### 停止

```shell
sh shutdown.sh
```

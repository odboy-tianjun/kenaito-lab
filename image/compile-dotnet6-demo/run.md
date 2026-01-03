# dotnet6 编译 + 运行示例

演示如何用本目录的两个镜像构建一个 .NET 6 Web 应用：

| 阶段 | 镜像                                                          | 说明                          |
|----|-------------------------------------------------------------|-----------------------------|
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet6` | 含 SDK 6.0.427（见上级 `Dockerfile`） |
| 运行 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-dotnet6` | 仅含 ASP.NET Core 运行时 6.0.35（见 `image/runtime-dotnet6`） |

编译环境镜像带 SDK 和整套编译工具链（体积大），只在构建阶段使用；运行阶段只拷贝 `dotnet publish` 的产物，
镜像里不带 SDK、源码和中间文件。

### 示例内容

```
demo/
├── Demo.csproj        # net6.0 Web 项目
├── Program.cs         # 最小 Web API：GET / 返回运行时信息，GET /health 健康检查
├── Dockerfile         # 两阶段构建：compile-dotnet6 -> runtime-dotnet6
├── build.sh           # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml # 部署编排（端口 8080，固定 IP 172.26.0.20）
├── install.sh         # docker-compose up -d
└── shutdown.sh        # docker-compose down
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-dotnet6 .
PUSH=1 sh build.sh     # 构建并推送
sh install.sh          # docker-compose -f docker-compose.yml -p dotnet6-demo up -d
```

访问：

```shell
curl http://192.168.235.104:8080/        # {"message":"dotnet6 is running","runtime":"6.0.35",...}
curl http://192.168.235.104:8080/health  # ok
```

### 关键点

**还原与发布分离**：先 `COPY` 只有 `*.csproj` 的一层执行 `dotnet restore`，再 `COPY` 源码 `dotnet publish --no-restore`。
源码改动不会让还原缓存失效，重复构建更快。多项目解决方案可按需增加 `COPY` 的 `*.sln` / `*.csproj` 文件。

**监听地址**：容器内监听 `8080`（`ASPNETCORE_URLS=http://0.0.0.0:8080`），不占用 80 端口，方便与宿主机其它服务共存。
镜像环境变量、compose 环境变量、部署时 `-e` 三者依次覆盖。

**时区**：镜像已内置 `TimeZone=Asia/Shanghai`，`DateTimeOffset.Now` 输出 +08:00；compose 中再用 `TZ` 显式声明一次。

**入口**：`ENTRYPOINT ["dotnet", "Demo.dll"]`，使用 exec 形式保证 `docker stop` 的 SIGTERM 能传到进程，优雅退出。

**健康检查**：运行镜像自带 `netstat`（`net-tools`），直接用端口探测，不需要额外安装 curl。

### 运维命令

```shell
docker logs -f dotnet6-demo          # 应用日志（stdout/stderr）
docker exec dotnet6-demo dotnet --info   # 确认运行时版本
docker exec dotnet6-demo sh -c 'ls /home/admin'
```

### 调试时直接在编译镜像里运行

需要看编译报错或临时跑一下时，可以只挂载源码进编译镜像（不需要构建镜像）：

```shell
docker run --rm -it -p 8080:8080 \
  -v "$PWD":/src -w /src \
  registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet6 \
  dotnet run
```

### 停止

```shell
sh shutdown.sh
```

# python310-flask 示例

演示如何用 `runtime-python310` 镜像构建并运行一个 Python 3.10 + Flask Web 应用：

| 阶段 | 镜像                                                              | 说明                                              |
| --- |-----------------------------------------------------------------|-------------------------------------------------|
| 编译 + 运行 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-python310` | 含 Python 3.10.0 与 pip 镜像源（见 `image/runtime-python310`） |

与 dotnet 示例不同，Python 是解释型语言，不需要单独的编译镜像：`pip install` 与直接运行都在同一个镜像内完成。

### 示例内容

```
demo/
├── app.py             # Flask 应用：GET / 运行时信息，GET /health，GET /api/hello/<name>，GET /page 页面
├── templates/
│   └── index.html     # /page 使用的 Jinja2 模板
├── requirements.txt   # 依赖清单（Flask 3.0.3）
├── Dockerfile         # 单阶段构建：runtime-python310
├── build.sh           # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml # 部署编排（端口 8083，固定 IP 172.30.0.20）
├── startup.sh         # docker-compose up -d
└── shutdown.sh        # docker-compose down
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-python310-flask .
PUSH=1 sh build.sh     # 构建并推送
sh startup.sh          # docker-compose -f docker-compose.yml -p python310-flask-demo up -d
```

访问：

```shell
curl http://127.0.0.1:8083/               # {"message":"python310-flask is running","python":"3.10.0",...}
curl http://127.0.0.1:8083/health         # ok
curl http://127.0.0.1:8083/api/hello/demo # {"message":"Hello, demo!",...}
```

浏览器打开 http://127.0.0.1:8083/page 可看到渲染后的运行信息页面。

### 关键点

**依赖层缓存**：先只 `COPY requirements.txt` 执行 `pip install`，再 `COPY` 源码。只改 `app.py` 时不会重装依赖，重复构建更快。
基础镜像已预置 `~/.pip/pip.conf` 指向阿里云源，`pip install` 无需额外换源。

**监听地址**：容器内监听 `8083`（`APP_PORT`），避开 dotnet6/8/9 示例占用的 8080/8081/8082；宿主机映射与容器端口一致。

**时区**：代码内统一按 UTC+8 输出时间，即使容器 `TZ` 未生效也不会差 8 小时；compose 中用 `TZ` 再显式声明一次。

**日志**：`PYTHONUNBUFFERED=1` 关闭 stdout 缓冲，`docker logs` 能实时看到请求日志；Flask 日志本身输出到 stderr。

**入口**：`ENTRYPOINT ["python", "app.py"]`，exec 形式保证 `docker stop` 的 SIGTERM 能传到进程。

**健康检查**：运行镜像自带 `net-tools`，直接用 `netstat` 探测端口，不需要额外安装 curl。

### 运维命令

```shell
docker logs -f python310-flask-demo        # 应用日志（stdout/stderr）
docker exec python310-flask-demo python -V # 确认 Python 版本
docker exec python310-flask-demo pip list  # 确认依赖版本
```

### 调试时直接在运行镜像里运行

需要临时改代码看效果时，可以只挂载源码进运行镜像（不需要构建镜像）：

```shell
docker run --rm -it -p 8083:8083 \
  -v "$PWD":/home/admin -w /home/admin \
  registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-python310 \
  sh -c 'pip install -r requirements.txt && python app.py'
```

### 生产运行

示例用 `app.run()` 的内置服务器，便于直接 `python app.py` 演示。生产环境建议换成 WSGI 服务器，
例如在 `requirements.txt` 增加 `gunicorn==21.2.0`，入口改为：

```dockerfile
ENTRYPOINT ["gunicorn", "-w", "4", "-b", "0.0.0.0:8083", "app:app"]
```

### 停止

```shell
sh shutdown.sh
```

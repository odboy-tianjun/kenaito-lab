# node 示例

演示如何用 `compile-node22` + `runtime-node22` 两阶段构建一个 Node.js 22 Web 服务。只用 Node 内置 `http` 模块，
无第三方依赖（`npm install` 不会真的下载东西），但依赖层写法按真实项目留好了。

| 阶段 | 镜像 | 说明 |
| --- | --- | --- |
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-node22` | Node + npm（源为 npmmirror）+ node-gyp 所需 python3/gcc |
| 运行 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-node22` | 仅 Node 运行时 |

### 示例内容

```
node/
├── package.json        # 无依赖；engines.node >= 20
├── server.js           # 内置 http：/、/api/info、/health、/api/hello、/page，带 SIGTERM 优雅关闭
├── Dockerfile          # 两阶段：compile-node22 -> runtime-node22，产物在 /out
├── build.sh            # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml  # 部署编排（端口 8087，固定 IP 172.31.1.20）
├── startup.sh          # docker-compose up -d
└── shutdown.sh         # docker-compose down
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-node .
PUSH=1 sh build.sh     # 构建并推送
sh startup.sh          # docker-compose -f docker-compose.yml -p node-demo up -d
```

访问：

```shell
curl http://127.0.0.1:8087/                # {"message":"node demo is running","node":"v22.x.x",...}
curl http://127.0.0.1:8087/health          # ok
curl http://127.0.0.1:8087/api/hello?name=demo
```

浏览器打开 http://127.0.0.1:8087/page 可看到 HTML 页面。

### 关键点

**依赖层缓存**：先 `COPY package.json package-lock.json*` 执行 `npm install --omit=dev`，再 `COPY` 源码。
源码改动不会让依赖安装层失效。本示例 `package.json` 里没有任何依赖，npm 不会创建 `node_modules`，
所以 Dockerfile 先判断有没有 `dependencies`/`devDependencies` 再决定是否安装——换成 express 等项目时加依赖即可，
Dockerfile 不用改。

**运行镜像只拷产物**：运行阶段分别 `COPY --from=build` 拷 `package.json`、`node_modules`（可选）与 `server.js`，
不额外收集到 `/out` 目录，避免“无依赖时目录不存在”导致构建失败。

**构建期自检**：`node --check server.js` 让语法错误在构建阶段就失败，而不是等容器启动。

**优雅关闭**：`ENTRYPOINT ["node", ...]` 让 node 成为 PID 1 直接收到 `docker stop` 的 SIGTERM；
`server.js` 里 `server.close()` 后退出，10 秒兜底强制退出。

**端口与 NODE_ENV**：8087，`NODE_ENV=production` 在 Dockerfile 与 compose 中都设置。

### 停止

```shell
sh shutdown.sh
```

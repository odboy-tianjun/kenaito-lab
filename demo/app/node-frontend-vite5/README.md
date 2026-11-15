# node-frontend-vite5 示例

**Vite 5** + Vue 3 的前端项目，用来和 `node-frontend-vue3`（Vite 7）对照：同一套两阶段构建，
只把构建工具降一个大版本。**构建阶段**用 `compile-node22`，**运行阶段**以自建 `proxy-tengine3` 托管静态文件。

| 阶段 | 镜像 | 说明 |
| --- | --- | --- |
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-node22` | Node 22 + npm（源为 npmmirror）；Vite 5 本身支持 Node 18+ |
| 运行 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:proxy-tengine3` | Tengine 3.1.0，托管 `dist/` |

纯前端项目：页面数据全部在浏览器内产生，不调用任何后端接口，部署只需要一个 Tengine 容器。

> 关于名字里的 “vite3”：Vite 3 已于 2022 年停止维护，且与当前 Node 22 组合缺少经过验证的插件版本；
> 这里按 **Vite 5** 实现（5.4.21），目录名保留 `vite5`。若必须用 Vite 3，请明确，我再降到对应依赖组合。

### 示例内容

```
node-frontend-vite5/
├── package.json           # vue 3.4.38 / vue-router 4.5.1；vite 5.4.21 + plugin-vue 5.1.4
├── vite.config.js         # base: './'；vue 单独拆包
├── index.html
├── src/
│   ├── main.js            # createApp + mount
│   ├── App.vue            # 单页：构建信息、计数器、时钟、import.meta.env 展示
│   └── styles.css         # 手写样式，不引 UI 库
├── nginx/
│   └── node-frontend-vite5.conf  # Tengine 站点配置：静态托管 + /healthz
├── Dockerfile             # 两阶段：compile-node22 -> proxy-tengine3
├── build.sh               # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml     # 只部署前端（端口 8092）
├── startup.sh / shutdown.sh
└── .dockerignore / .gitignore
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-node-frontend-vite5 .
PUSH=1 sh build.sh     # 构建并推送
sh startup.sh          # docker-compose -f docker-compose.yml -p node-frontend-vite5-demo up -d
```

访问 http://127.0.0.1:8092/ ；`curl http://127.0.0.1:8092/healthz` 返回 `ok`。

### 本地开发（不用 docker）

```shell
npm install
npm run dev      # http://127.0.0.1:5473
```

### 关键点

**import.meta.env**：Vite 在构建时把 `import.meta.env.MODE/PROD/BASE_URL` 静态替换成字面量，
页面直接展示出来便于确认构建模式；生产包里不会带上其它环境变量。

**与 Vite 7 的差异**：配置项写法基本一致（`plugins` / `base` / `build.rollupOptions`），
主要区别是 Vite 5 对 Node 版本要求更低、以及 Vite 6+ 才有的 Environment API 等新特性在本示例中没用到。

**站点配置**：配置放在 `nginx/node-frontend-vite5.conf`，构建时 `COPY` 到 `/usr/local/nginx/conf/conf.d/`；
compose 把宿主机 `./nginx` 挂到同一个 `conf.d`，改完 `nginx -t && nginx -s reload` 生效。
挂目录而不是单文件：单文件挂载编辑会换 inode，容器内看不到改动。

### 停止

```shell
sh shutdown.sh
```

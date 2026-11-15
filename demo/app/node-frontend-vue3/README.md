# node-frontend-vue3 示例

Vue 3 + Element Plus 的前端项目，**构建阶段**用 `compile-node22` 跑 Vite，**运行阶段**以自建
`proxy-tengine3` 镜像为基座托管静态文件。与 [`node-frontend-vue2`](../node-frontend-vue2/README.md) 对照，
差别只在框架版本与 UI 库。

| 阶段 | 镜像 | 说明 |
| --- | --- | --- |
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-node22` | Node 22 + npm（源为 npmmirror），Vite 7 要求 Node ≥ 20.19 |
| 运行 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:proxy-tengine3` | Tengine 3.1.0，托管 `dist/` |

纯前端项目：页面数据全部在浏览器内产生，不调用任何后端接口，部署只需要一个 Tengine 容器。

### 示例内容

```
node-frontend-vue3/
├── package.json           # vue 3.5.45 / element-plus 2.14.8 / vue-router 4.6.5；vite 7 + plugin-vue 6
├── vite.config.js         # base: './'；element-plus 单独拆包
├── index.html
├── src/
│   ├── main.js            # createApp().use(router).use(ElementPlus)
│   ├── router.js          # createWebHashHistory，/ /form /about
│   ├── App.vue            # <script setup>，顶部导航 + router-view
│   └── views/
│       ├── HomeView.vue   # ref/computed + onMounted 时钟，el-statistic / el-rate / el-progress
│       ├── FormView.vue   # el-form 校验、el-select、el-date-picker，value-format="YYYY-MM-DD"
│       └── AboutView.vue  # 版本与部署说明
├── nginx/
│   └── node-frontend-vue3.conf  # Tengine 站点配置：静态托管 + /healthz
├── Dockerfile             # 两阶段：compile-node22 -> proxy-tengine3
├── build.sh               # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml     # 只部署前端（端口 8090）
├── startup.sh / shutdown.sh
└── .dockerignore / .gitignore
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-node-frontend-vue3 .
PUSH=1 sh build.sh     # 构建并推送
sh startup.sh          # docker-compose -f docker-compose.yml -p node-frontend-vue3-demo up -d
```

访问 http://127.0.0.1:8090/ ；`curl http://127.0.0.1:8090/healthz` 返回 `ok`。

### 本地开发（不用 docker）

```shell
npm install
npm run dev      # http://127.0.0.1:5273
```

### 关键点

**为什么用 Tengine 托管而不是 Node 托管**：Vue 打包后是纯静态文件，用 `proxy-tengine3` 直接托管，
运行阶段不保留 Node/npm，镜像更小，也能顺手用 Tengine 做 gzip 与缓存。

**站点配置**：配置放在 `nginx/node-frontend-vue3.conf`，构建时 `COPY` 到 `/usr/local/nginx/conf/conf.d/`
（镜像自带 nginx.conf 已经 `include conf.d/*.conf`）；compose 又把宿主机 `./nginx` 挂到同一个 `conf.d`，
改完执行 `nginx -t && nginx -s reload` 即生效。挂目录而不是单文件：单文件挂载编辑会换 inode，容器内看不到改动。

**路由模式**：`createWebHashHistory`，部署到任何路径都不用 rewrite；要换 history 模式，
`try_files` 已经写好，改 `router.js` 即可。

**与 Vue 2 版差异**：`<script setup>`、`ref/computed`、`createApp`、Element Plus 的
`el-date-picker` 用 `value-format="YYYY-MM-DD"`（Vue 2 + Element UI 是 `yyyy-MM-dd`）。

### 停止

```shell
sh shutdown.sh
```

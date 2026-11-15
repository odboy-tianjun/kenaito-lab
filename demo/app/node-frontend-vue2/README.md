# node-frontend-vue2 示例

Vue 2.7 + Element UI 2 的前端项目，**构建阶段**用 `compile-node22` 跑 Vite，**运行阶段**直接以自建
`proxy-tengine3` 镜像为基座托管静态文件，不再额外起 Node 容器。

| 阶段 | 镜像 | 说明 |
| --- | --- | --- |
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-node22` | Node 22 + npm（源为 npmmirror），Vite 7 要求 Node ≥ 20.19 |
| 运行 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:proxy-tengine3` | Tengine 3.1.0，托管 `dist/` |

纯前端项目：页面数据全部在浏览器内产生，不调用任何后端接口，部署只需要一个 Tengine 容器。

### 示例内容

```
node-frontend-vue2/
├── package.json           # vue 2.7.16 / element-ui 2.15.14 / vue-router 3.6.5；vite 7 + plugin-vue2
├── vite.config.js         # base: './'；element-ui 单独拆包
├── index.html
├── src/
│   ├── main.js            # Vue.use(ElementUI)
│   ├── router.js          # hash 模式，/ /form /about
│   ├── App.vue            # 顶部导航 + router-view
│   └── views/
│       ├── Home.vue       # 计数器、时钟、el-statistic / el-rate / el-progress 等组件一览
│       ├── Form.vue       # el-form 校验、el-select、el-date-picker 等常用组件
│       └── About.vue      # 版本与部署说明
├── nginx/
│   └── node-frontend-vue2.conf  # Tengine 站点配置：静态托管 + /healthz
├── Dockerfile             # 两阶段：compile-node22 -> proxy-tengine3
├── build.sh               # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml     # 只部署前端（端口 8089）
├── startup.sh / shutdown.sh
└── .dockerignore / .gitignore
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-node-frontend-vue2 .
PUSH=1 sh build.sh     # 构建并推送
sh startup.sh          # docker-compose -f docker-compose.yml -p node-frontend-vue2-demo up -d
```

访问 http://127.0.0.1:8089/ ：首页、表单页、关于页都是纯前端页面，不依赖任何后端容器。

```shell
curl http://127.0.0.1:8089/healthz   # ok
```

### 本地开发（不用 docker）

```shell
npm install
npm run dev      # http://127.0.0.1:5173
```

### 关键点

**为什么用 Tengine 托管而不是 Node 托管**：Vue 打包后是纯静态文件，用 `proxy-tengine3` 直接托管，
运行阶段不保留 Node/npm，镜像更小，也能顺手用 Tengine 做 gzip、缓存和反向代理。

**站点配置**：配置放在 `nginx/node-frontend-vue2.conf`。构建时文件被 `COPY` 到 `/usr/local/nginx/conf/conf.d/`
（镜像自带的 nginx.conf 已经 `include conf.d/*.conf`）；compose 又把宿主机的 `./nginx` 目录挂载到同一个
`conf.d`，所以改完配置执行
`docker exec node-frontend-vue2-demo nginx -t && docker exec node-frontend-vue2-demo nginx -s reload` 即生效，不必重建镜像。
挂目录而不是挂单文件：单文件挂载在宿主机上编辑会换 inode，容器内看不到改动。
`/assets/` 长缓存（文件带 hash），`/` 用 `try_files $uri $uri/ /index.html` 兜底。

**路由模式**：示例用 hash 模式，部署到任何路径都不用额外 rewrite；要换 history 模式，`try_files` 已经写好，
改 `router.js` 的 `mode` 即可。

**前后端分离部署**：本示例是纯静态前端，只负责页面渲染，不代理任何接口。实际项目里后端是独立服务、
配有自己的域名（如 `api.example.com`），由前端直接跨域调用或由统一的网关处理；本仓库不预置任何后端容器，
也不在站点配置里写 `proxy_pass` 上游——这样构建阶段不在业务网络里也能直接 `nginx -t` 通过。
如果某个部署环境确实需要同域转发，再在那个环境的配置里单独加 `location` 即可，不影响本示例。

**依赖版本**：Vue 2.7.16 是 Vue 2 的最后一个版本（内置组合式 API，但示例仍用选项式写法），
`@vitejs/plugin-vue2` 负责让 Vite 7 编译 `.vue` 单文件组件。

### 停止

```shell
sh shutdown.sh
```

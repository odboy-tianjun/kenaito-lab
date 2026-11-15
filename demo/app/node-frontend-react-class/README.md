# node-frontend-react-class 示例

React 19 **类组件**（class component）写法的前端项目，**构建阶段**用 `compile-node22` 跑 Vite，**运行阶段**以自建
`proxy-tengine3` 镜像为基座托管静态文件。函数组件 + Hooks 写法见同级的
[`node-frontend-react-function`](../node-frontend-react-function/README.md)，两者页面与部署方式完全一致，只差组件写法。

| 阶段 | 镜像 | 说明 |
| --- | --- | --- |
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-node22` | Node 22 + npm（源为 npmmirror），Vite 7 要求 Node ≥ 20.19 |
| 运行 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:proxy-tengine3` | Tengine 3.1.0，托管 `dist/` |

纯前端项目：页面数据全部在浏览器内产生，不调用任何后端接口，部署只需要一个 Tengine 容器。

### 示例内容

```
node-frontend-react-class/
├── package.json           # react 19.3.1 / react-dom 19.3.1；vite 7 + plugin-react 5
├── vite.config.js         # base: './'；react/react-dom 单独拆包
├── index.html
├── src/
│   ├── main.jsx           # createRoot + StrictMode
│   ├── App.jsx            # class App extends Component，this.state 切换页签
│   ├── styles.css         # 轻量手写样式，不引 UI 库
│   └── views/
│       ├── Home.jsx       # this.state + componentDidMount/WillUnmount：计数器、时钟、受控输入
│       ├── Form.jsx       # 类组件受控表单 + validate，错误/结果放 this.state
│       └── About.jsx      # 版本与部署说明（无状态类组件）
├── nginx/
│   └── node-frontend-react-class.conf  # Tengine 站点配置：静态托管 + /healthz
├── Dockerfile             # 两阶段：compile-node22 -> proxy-tengine3
├── build.sh               # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml     # 只部署前端（端口 8093）
├── startup.sh / shutdown.sh
└── .dockerignore / .gitignore
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-node-frontend-react-class .
PUSH=1 sh build.sh     # 构建并推送
sh startup.sh          # docker-compose -f docker-compose.yml -p node-frontend-react-class-demo up -d
```

访问 http://127.0.0.1:8093/ ；`curl http://127.0.0.1:8093/healthz` 返回 `ok`。

### 本地开发（不用 docker）

```shell
npm install
npm run dev      # http://127.0.0.1:5573
```

### 关键点

**类组件写法**：组件继承 `Component`，状态放 `this.state`、更新用 `this.setState`；定时器在
`componentDidMount` 里创建、`componentWillUnmount` 里清理（对应函数版的 `useEffect` cleanup）。
事件处理函数在构造函数里 `bind(this)`，或用箭头函数保持 `this`。

**函数版 vs 类版**：这是官方文档并列的两种写法，行为等价。新代码建议用函数组件 + Hooks
（见 `node-frontend-react-function`）；类组件在旧项目、错误边界（`componentDidCatch`）里仍会遇到。

**站点配置**：配置放在 `nginx/node-frontend-react-class.conf`，构建时 `COPY` 到 `/usr/local/nginx/conf/conf.d/`
（镜像自带 nginx.conf 已经 `include conf.d/*.conf`）；compose 又把宿主机 `./nginx` 挂到同一个 `conf.d`。
挂目录而不是单文件：单文件挂载编辑会换 inode，容器内看不到改动。

### 停止

```shell
sh shutdown.sh
```

# dockerfiles

应用环境镜像定制（alinux3）与中间件部署编排。镜像仓库：`registry.cn-shanghai.aliyuncs.com/odboy/`

```
top/
├── image/  自建镜像：每个目录 = Dockerfile + build.sh，目录名即镜像 tag
└── app/    部署编排：每个目录 = docker-compose.yml + install.sh / shutdown.sh + run.md(+demo.png)
```

### 使用约定

- 所有自建镜像都基于 `kenaito:alinux3-update20261111` 构建，先构建基础镜像，再构建上层镜像
- 镜像目录：`cd top/image/<目录> && sh build.sh`（构建并推送，镜像 tag 写在 `build.sh` 的 `IMAGE` 变量，与目录名一致）
- 部署目录：`cd top/app/<目录> && sh install.sh`，`sh shutdown.sh` 停止；每个目录自洽，不依赖仓库其它层级
- 部署目录中使用的第三方镜像（MySQL、Nacos、Zookeeper、RocketMQ、EFK、SkyWalking 等）均同步到了
  `registry.cn-shanghai.aliyuncs.com/odboy/<原名>:<版本>`，注释里保留原镜像名

### 自建镜像

| 目录                                      | 镜像 tag                       | 基础镜像 / 版本                       | 说明                                         |
|-----------------------------------------|------------------------------|--------------------------------|--------------------------------------------|
| `top/image/alinux3-update20261111`      | `kenaito:alinux3-update20261111` | 阿里云 alinux3 3.13.3            | 系统基础镜像，其余镜像均基于它                            |
| `top/image/runtime-jdk11`               | `kenaito:runtime-jdk11`      | 上者 / JDK 11                  | 运行环境，仅 JDK                                |
| `top/image/runtime-jdk17`               | `kenaito:runtime-jdk17`      | 上者 / JDK 17                  | 运行环境，仅 JDK                                |
| `top/image/runtime-jdk21`               | `kenaito:runtime-jdk21`      | 上者 / JDK 21.0.2              | 运行环境，仅 JDK                                |
| `top/image/runtime-python3`             | `kenaito:runtime-python3`    | 上者 / Python 3.10.0           | 运行环境，Python + pip 源（`pip.conf`）           |
| `top/image/runtime-dotnet6`             | `kenaito:runtime-dotnet6`    | 上者 / ASP.NET Core 运行时 6.0.35 | 运行环境，仅运行时                                  |
| `top/image/runtime-dotnet8`             | `kenaito:runtime-dotnet8`    | 上者 / ASP.NET Core 运行时 8.0.x  | 运行环境，仅运行时                                  |
| `top/image/runtime-dotnet9`             | `kenaito:runtime-dotnet9`    | 上者 / ASP.NET Core 运行时 9.0.x  | 运行环境，仅运行时                                  |
| `top/image/compile-dotnet6`             | `kenaito:compile-dotnet6`    | 上者 / .NET SDK 6.0.427        | 编译环境（SDK + 编译工具链），附两阶段构建示例 `demo/`         |
| `top/image/compile-dotnet8`             | `kenaito:compile-dotnet8`    | 上者 / .NET SDK 8.0.403        | 编译环境（SDK + 编译工具链）                          |
| `top/image/compile-dotnet9`             | `kenaito:compile-dotnet9`    | 上者 / .NET SDK 9.0.100-rc.2   | 编译环境（SDK + 编译工具链）                          |
| `top/image/proxy-tengine3`              | `kenaito:proxy-tengine3`     | 上者 / Tengine 3.1.0 源码编译      | 反向代理 / Web 服务器，自定义 `nginx.conf`           |
| `top/image/tools-ansible`               | `kenaito:tools-ansible`      | 上者 / Python 3.10.0 + Ansible  | 运维工具镜像                                     |

### 部署编排

| 目录                                        | 组件与版本                                | 端口                                  | 说明 / 依赖                         |
|-------------------------------------------|--------------------------------------|-------------------------------------|---------------------------------|
| `top/app/nacos-2.5.0-standalone`          | Nacos 2.5.0 + MySQL 8.0              | 8848、9848、3308                       | 单机 Nacos，MySQL 存储，含建库脚本        |
| `top/app/nacos-2.5.0-cluster`             | Nacos 2.5.0 ×3 + MySQL 8.0           | 8848-8850、9848-9849、7850、3308        | 三节点集群，MySQL 存储                 |
| `top/app/dubbo-admin-0.6.0-standalone`    | Dubbo Admin 0.6.0 + Zookeeper 3.9.3  | 38080、2181                          | 单机 Dubbo 管控台                    |
| `top/app/dubbo-admin-0.6.0-cluster`       | Dubbo Admin 0.6.0 + Zookeeper 3.9.3 ×3 | 38080、2181-2183                    | Zookeeper 三节点集群                 |
| `top/app/zookeeper-3.8.4-standalone`      | Zookeeper 3.8.4                      | 2181                                | 单机                             |
| `top/app/zookeeper-3.8.4-cluster`         | Zookeeper 3.8.4 ×3                   | 2181-2183                           | 三节点集群                          |
| `top/app/zookeeper-3.9.3-standalone`      | Zookeeper 3.9.3                      | 2181                                | 单机                             |
| `top/app/zookeeper-3.9.3-cluster`         | Zookeeper 3.9.3 ×3                   | 2181-2183                           | 三节点集群                          |
| `top/app/rocketmq-4.9.6-standalone`       | RocketMQ 4.9.6 + Dashboard           | 9876、10909-10912                    | 单 Namesrv + 单 Broker            |
| `top/app/rocketmq-4.9.6-cluster-1m2s`     | RocketMQ 4.9.6 + Dashboard           | 9876、10909-10912                    | 单 Master + 双 Slave              |
| `top/app/rocketmq-4.9.6-cluster-2m`       | RocketMQ 4.9.6                       | 9876、10709-10712                     | 双 Master（无 Slave）                |
| `top/app/efk`                             | Elasticsearch / Kibana / Filebeat 7.14.1 | 9200、9300、5601                  | 日志采集 + 搜索 + 展示，含 ik 分词          |
| `top/app/skywalking-9.5.0-es`             | SkyWalking OAP / UI 9.5.0 + ES 7.14.1 | 11800、12800、18080、9200、9300         | 链路追踪，ES 存储                     |
| `top/app/skywalking-9.5.0-mysql`          | SkyWalking OAP / UI 9.5.0 + MySQL 8.0 | 11800、12800、18080、3308              | 链路追踪，MySQL 存储                   |
| `top/app/skywalking-9.7.0-es`             | SkyWalking OAP / UI 9.7.0 + ES 7.14.1 | 11800、12800、18080、9200、9300         | 链路追踪，ES 存储                     |
| `top/app/skywalking-9.7.0-mysql`          | SkyWalking OAP / UI 9.7.0 + MySQL 8.0 | 11800、12800、18080、3308              | 链路追踪，MySQL 存储                   |
| `top/app/skywalking-10.0.1-es`            | SkyWalking OAP / UI 10.0.1 + ES 7.14.1 | 11800、12800、18080、9200、9300         | 链路追踪，ES 存储                     |
| `top/app/skywalking-10.0.1-mysql`         | SkyWalking OAP / UI 10.0.1 + MySQL 8.0 | 11800、12800、18080、3308              | 链路追踪，MySQL 存储                   |
| `top/app/skywalking-9.5.0-agent`          | SkyWalking Java Agent 8.15.0         | -                                   | 应用接入 agent 包（仅 `*.tgz`，无编排）      |
| `top/app/skywalking-9.7.0-agent`          | SkyWalking Java Agent 9.1.0          | -                                   | 应用接入 agent 包（仅 `*.tgz`，无编排）      |
| `top/app/skywalking-10.0.1-agent`         | SkyWalking Java Agent 9.3.0          | -                                   | 应用接入 agent 包（仅 `*.tgz`，无编排）      |
| `top/app/tengine-3.1.0`                   | Tengine 3.1.0（`proxy-tengine3` 镜像）  | 80、443                             | 反代示例，证书与站点配置挂载目录               |

每个目录下的 `run.md` 有详细的部署命令、访问地址与示例图，完整索引见 [docs/index.md](docs/index.md)。

# 支持的语言
- dotnet 适用于 dotnet 应用
  - 编译：`runtime-dotnet*` 之上的 `compile-dotnet*`
  - 运行：`runtime-dotnet*`
- java 适用于 java 应用
  - 编译与运行：`runtime-jdk*`（含 JDK，可直接编译后运行）
- python 适用于 python 应用
  - 编译与运行：`runtime-python3`（已配置 pip 镜像源）

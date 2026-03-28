# dockerfiles

应用环境镜像定制（alinux3）与中间件部署编排。镜像仓库：`registry.cn-shanghai.aliyuncs.com/odboy/`

```
image/  自建镜像：每个目录 = Dockerfile + build.sh，目录名即镜像 tag
app/    部署编排：每个目录 = docker-compose.yml + install.sh / shutdown.sh + run.md(+demo.png)
        app/ansible 例外：基于 runtime-python310 构建 ansible 镜像
demo/   构建示例：演示如何基于 image/ 下的镜像做两阶段构建（dotnet6 / dotnet8 / dotnet9）
```

### 使用约定

- 所有自建镜像都基于 `kenaito:system-alinux3` 构建，先构建基础镜像，再构建上层镜像
- 镜像目录：`cd image/<目录> && sh build.sh`（构建并推送，镜像 tag 写在 `build.sh` 的 `IMAGE` 变量，与目录名一致）
- 部署目录：`cd app/<目录> && sh install.sh`，`sh shutdown.sh` 停止；每个目录自洽，不依赖仓库其它层级
- 部署目录中使用的第三方镜像（MySQL、Nacos、Zookeeper、RocketMQ、EFK、SkyWalking 等）均同步到了
  `registry.cn-shanghai.aliyuncs.com/odboy/<原名>:<版本>`，注释里保留原镜像名

### 自建镜像

目录名即镜像 tag，镜像全名 `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:<目录名>`。

| 目录                           | 镜像 tag                         | 基础镜像 / 版本                   | 说明                                                                     |
| ------------------------------ | -------------------------------- | --------------------------------- | ------------------------------------------------------------------------ |
| `image/system-alinux3`         | `kenaito:system-alinux3`         | 阿里云 alinux3 3.13.3             | 系统基础镜像，其余镜像均基于它                                           |
| `image/runtime-jdk11`          | `kenaito:runtime-jdk11`          | 上者 / JDK 11                     | 运行环境，仅 JDK                                                         |
| `image/runtime-jdk17`          | `kenaito:runtime-jdk17`          | 上者 / JDK 17                     | 运行环境，仅 JDK                                                         |
| `image/runtime-jdk21`          | `kenaito:runtime-jdk21`          | 上者 / JDK 21.0.2                 | 运行环境，仅 JDK                                                         |
| `image/runtime-python310`      | `kenaito:runtime-python310`      | 上者 / Python 3.10.0              | 运行环境，Python + pip 源（`pip.conf`）                                  |
| `image/runtime-dotnet6`        | `kenaito:runtime-dotnet6`        | 上者 / ASP.NET Core 运行时 6.0.35 | 运行环境，仅运行时                                                       |
| `image/runtime-dotnet8`        | `kenaito:runtime-dotnet8`        | 上者 / ASP.NET Core 运行时 8.0.x  | 运行环境，仅运行时                                                       |
| `image/runtime-dotnet9`        | `kenaito:runtime-dotnet9`        | 上者 / ASP.NET Core 运行时 9.0.x  | 运行环境，仅运行时                                                       |
| `image/compile-dotnet6`        | `kenaito:compile-dotnet6`        | 上者 / .NET SDK 6.0.427           | 编译环境（SDK + 编译工具链），两阶段构建示例见 `demo/dotnet6` |
| `image/compile-dotnet8`        | `kenaito:compile-dotnet8`        | 上者 / .NET SDK 8.0.403           | 编译环境（SDK + 编译工具链），两阶段构建示例见 `demo/dotnet8` |
| `image/compile-dotnet9`        | `kenaito:compile-dotnet9`        | 上者 / .NET SDK 9.0.100-rc.2      | 编译环境（SDK + 编译工具链），两阶段构建示例见 `demo/dotnet9` |
| `image/proxy-tengine3`         | `kenaito:proxy-tengine3`         | 上者 / Tengine 3.1.0 源码编译     | 反向代理 / Web 服务器，自定义 `nginx.conf`                               |
| `app/ansible`                  | `kenaito:ansible`                | 上者 / Ansible（基于 runtime-python310） | 运维工具镜像                                                     |

### 部署编排

每个目录的 `run.md` 有部署命令、访问地址与示例图。

| 目录（链接指向 `run.md` 或目录说明）                                          | 组件与版本                               | 端口                              | 说明 / 依赖                                            |
| ----------------------------------------------------------------------------- | ---------------------------------------- | --------------------------------- | ------------------------------------------------------ |
| [`app/nacos-2.5.0-standalone`](app/nacos-2.5.0-standalone/run.md)             | Nacos 2.5.0 + MySQL 8.0                  | 8848、9848、3308                  | 单机 Nacos，MySQL 存储，含建库脚本                     |
| [`app/nacos-2.5.0-cluster`](app/nacos-2.5.0-cluster/run.md)                   | Nacos 2.5.0 ×3 + MySQL 8.0               | 8848-8850、9848-9849、7850、3308  | 三节点集群，MySQL 存储                                 |
| [`app/dubbo-admin-0.6.0-standalone`](app/dubbo-admin-0.6.0-standalone/run.md) | Dubbo Admin 0.6.0 + Zookeeper 3.9.3      | 38080、2181                       | 单机 Dubbo 管控台                                      |
| [`app/dubbo-admin-0.6.0-cluster`](app/dubbo-admin-0.6.0-cluster/run.md)       | Dubbo Admin 0.6.0 + Zookeeper 3.9.3 ×3   | 38080、2181-2183                  | Zookeeper 三节点集群                                   |
| [`app/zookeeper-3.8.4-standalone`](app/zookeeper-3.8.4-standalone/run.md)     | Zookeeper 3.8.4                          | 2181                              | 单机                                                   |
| [`app/zookeeper-3.8.4-cluster`](app/zookeeper-3.8.4-cluster/run.md)           | Zookeeper 3.8.4 ×3                       | 2181-2183                         | 三节点集群                                             |
| [`app/zookeeper-3.9.3-standalone`](app/zookeeper-3.9.3-standalone/run.md)     | Zookeeper 3.9.3                          | 2181                              | 单机                                                   |
| [`app/zookeeper-3.9.3-cluster`](app/zookeeper-3.9.3-cluster/run.md)           | Zookeeper 3.9.3 ×3                       | 2181-2183                         | 三节点集群                                             |
| [`app/rocketmq-4.9.6-standalone`](app/rocketmq-4.9.6-standalone/run.md)       | RocketMQ 4.9.6 + Dashboard               | 9876、10909-10912                 | 单 Namesrv + 单 Broker                                 |
| [`app/rocketmq-4.9.6-cluster-1m2s`](app/rocketmq-4.9.6-cluster-1m2s/run.md)   | RocketMQ 4.9.6 + Dashboard               | 9876、10909-10912                 | 单 Master + 双 Slave                                   |
| [`app/rocketmq-4.9.6-cluster-2m`](app/rocketmq-4.9.6-cluster-2m/run.md)       | RocketMQ 4.9.6                           | 9876、10709-10712                 | 双 Master（无 Slave）                                  |
| [`app/efk`](app/efk/run.md)                                                   | Elasticsearch / Kibana / Filebeat 7.14.1 | 9200、9300、5601                  | 日志采集 + 搜索 + 展示，含 ik 分词                     |
| [`app/skywalking-9.5.0-es`](app/skywalking-9.5.0-es/run.md)                   | SkyWalking OAP / UI 9.5.0 + ES 7.14.1    | 11800、12800、18080、9200、9300   | 链路追踪，ES 存储                                      |
| [`app/skywalking-9.5.0-mysql`](app/skywalking-9.5.0-mysql/run.md)             | SkyWalking OAP / UI 9.5.0 + MySQL 8.0    | 11800、12800、18080、3308         | 链路追踪，MySQL 存储                                   |
| [`app/skywalking-9.5.0-agent`](app/skywalking-9.5.0-agent/README.md)          | SkyWalking Java Agent 8.15.0             | -                                 | 应用接入 agent 包（仅 `*.tgz`，无编排）                |
| [`app/skywalking-9.7.0-es`](app/skywalking-9.7.0-es/run.md)                   | SkyWalking OAP / UI 9.7.0 + ES 7.14.1    | 11800、12800、18080、9200、9300   | 链路追踪，ES 存储                                      |
| [`app/skywalking-9.7.0-mysql`](app/skywalking-9.7.0-mysql/run.md)             | SkyWalking OAP / UI 9.7.0 + MySQL 8.0    | 11800、12800、18080、3308         | 链路追踪，MySQL 存储                                   |
| [`app/skywalking-9.7.0-agent`](app/skywalking-9.7.0-agent/README.md)          | SkyWalking Java Agent 9.1.0              | -                                 | 应用接入 agent 包（仅 `*.tgz`，无编排）                |
| [`app/skywalking-10.0.1-es`](app/skywalking-10.0.1-es/run.md)                 | SkyWalking OAP / UI 10.0.1 + ES 7.14.1   | 11800、12800、18080、9200、9300   | 链路追踪，ES 存储                                      |
| [`app/skywalking-10.0.1-mysql`](app/skywalking-10.0.1-mysql/run.md)           | SkyWalking OAP / UI 10.0.1 + MySQL 8.0   | 11800、12800、18080、3308         | 链路追踪，MySQL 存储                                   |
| [`app/skywalking-10.0.1-agent`](app/skywalking-10.0.1-agent/README.md)        | SkyWalking Java Agent 9.3.0              | -                                 | 应用接入 agent 包（仅 `*.tgz`，无编排）                |
| [`app/tengine-3.1.0`](app/tengine-3.1.0/run.md)                               | Tengine 3.1.0（`proxy-tengine3` 镜像）   | 80、443                           | 反代示例，证书与站点配置挂载目录                       |

同版本的 ES / MySQL / Agent 三种形态目录并列，按需选择其一部署；ES 形态与 MySQL 形态端口相同，不要同时启动。

# 支持的语言
- dotnet 适用于 dotnet 应用
  - 编译：`runtime-dotnet*` 之上的 `compile-dotnet*`
  - 运行：`runtime-dotnet*`
- java 适用于 java 应用
  - 编译与运行：`runtime-jdk*`（含 JDK，可直接编译后运行）
- python 适用于 python 应用
  - 编译与运行：`runtime-python310`（已配置 pip 镜像源）

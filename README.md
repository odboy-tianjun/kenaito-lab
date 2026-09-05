# dockerfiles

应用环境镜像定制（alinux3）与中间件部署编排。镜像仓库：`registry.cn-shanghai.aliyuncs.com/odboy/`

```
image/  自建镜像：每个目录 = Dockerfile + build.sh，目录名即镜像 tag
deploy/ 部署编排：三方镜像 + 自研的 docker-compose / 配置，每个目录 = docker-compose.yml + startup.sh / shutdown.sh + README.md(+demo.png)
demo/   构建示例：基于 image/ 下的镜像做构建与运行演示（dotnet6/8/9、python310-flask、tengine3）
```

### 使用约定

- 所有自建镜像都基于 `kenaito:system-alinux3` 构建，先构建基础镜像，再构建上层镜像
- 镜像目录：`cd image/<目录> && sh build.sh`（构建并推送，镜像 tag 写在 `build.sh` 的 `IMAGE` 变量，与目录名一致）
- 部署目录：`cd deploy/<目录> && sh startup.sh`，`sh shutdown.sh` 停止；每个目录自洽，不依赖仓库其它层级
- 部署目录中使用的第三方镜像（MySQL、Nacos、Zookeeper、RocketMQ、EFK、SkyWalking 等）均同步到了
  `registry.cn-shanghai.aliyuncs.com/odboy/thirdrepo:<原名>-<版本>`，注释里保留原镜像名（如
  `thirdrepo:nacos-server-2.5.5`、`thirdrepo:zookeeper-3.9.3`）；RocketMQ 与 SkyWalking 仍沿用
  `odboy/apache-rocketmq:<版本>`、`odboy/skywalking-oap-server:<版本>` 等旧命名

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
| `image/tools-ansible`          | `kenaito:ansible`                | 上者 / Ansible（基于 runtime-python315） | 运维工具镜像，锁定 ansible-core 2.16.3                     |

### 部署编排

每个目录的 `README.md` 有部署命令、访问地址与示例图。

| 目录（链接指向 `README.md` 或目录说明）                                          | 组件与版本                               | 端口                              | 说明 / 依赖                                            |
| ----------------------------------------------------------------------------- | ---------------------------------------- | --------------------------------- | ------------------------------------------------------ |
| [`deploy/nacos-2.5.5-standalone`](deploy/nacos-2.5.5-standalone/README.md)             | Nacos 2.5.5 + MySQL 8.0                  | 8848、9848、3308                  | 单机 Nacos，MySQL 存储，含建库脚本                     |
| [`deploy/nacos-2.5.5-cluster`](deploy/nacos-2.5.5-cluster/README.md)                   | Nacos 2.5.5 ×3 + MySQL 8.0               | 8848-8850、9848-9849、7850、3308  | 三节点集群，MySQL 存储                                 |
| [`deploy/dubbo-admin-0.6.0-standalone`](deploy/dubbo-admin-0.6.0-standalone/README.md) | Dubbo Admin 0.6.0 + Zookeeper 3.9.3      | 38080、2181                       | 单机 Dubbo 管控台                                      |
| [`deploy/dubbo-admin-0.6.0-cluster`](deploy/dubbo-admin-0.6.0-cluster/README.md)       | Dubbo Admin 0.6.0 + Zookeeper 3.9.3 ×3   | 38080、2181-2183                  | Zookeeper 三节点集群                                   |
| [`deploy/zookeeper-3.8.4-standalone`](deploy/zookeeper-3.8.4-standalone/README.md)     | Zookeeper 3.8.4                          | 2181                              | 单机                                                   |
| [`deploy/zookeeper-3.8.4-cluster`](deploy/zookeeper-3.8.4-cluster/README.md)           | Zookeeper 3.8.4 ×3                       | 2181-2183                         | 三节点集群                                             |
| [`deploy/zookeeper-3.9.3-standalone`](deploy/zookeeper-3.9.3-standalone/README.md)     | Zookeeper 3.9.3                          | 2181                              | 单机                                                   |
| [`deploy/zookeeper-3.9.3-cluster`](deploy/zookeeper-3.9.3-cluster/README.md)           | Zookeeper 3.9.3 ×3                       | 2181-2183                         | 三节点集群                                             |
| [`deploy/rocketmq-4.9.6-standalone`](deploy/rocketmq-4.9.6-standalone/README.md)       | RocketMQ 4.9.6 + Dashboard               | 9876、10909-10912                 | 单 Namesrv + 单 Broker                                 |
| [`deploy/rocketmq-4.9.6-cluster-1m2s`](deploy/rocketmq-4.9.6-cluster-1m2s/README.md)   | RocketMQ 4.9.6 + Dashboard               | 9876、10909-10912                 | 单 Master + 双 Slave                                   |
| [`deploy/rocketmq-4.9.6-cluster-2m`](deploy/rocketmq-4.9.6-cluster-2m/README.md)       | RocketMQ 4.9.6                           | 9876、10709-10712                 | 双 Master（无 Slave）                                  |
| [`deploy/efk`](deploy/efk/README.md)                                                   | Elasticsearch / Kibana / Filebeat 7.14.1 | 9200、9300、5601                  | 日志采集 + 搜索 + 展示，含 ik 分词                     |
| [`deploy/skywalking-9.5.0-es`](deploy/skywalking-9.5.0-es/README.md)                   | SkyWalking OAP / UI 9.5.0 + ES 7.14.1    | 11800、12800、18080、9200、9300   | 链路追踪，ES 存储                                      |
| [`deploy/skywalking-9.5.0-mysql`](deploy/skywalking-9.5.0-mysql/README.md)             | SkyWalking OAP / UI 9.5.0 + MySQL 8.0    | 11800、12800、18080、3308         | 链路追踪，MySQL 存储                                   |
| [`deploy/skywalking-9.5.0-agent`](deploy/skywalking-9.5.0-agent/README.md)          | SkyWalking Java Agent 8.15.0             | -                                 | 应用接入 agent 包（OSS 下载，无编排）                  |
| [`deploy/skywalking-9.7.0-es`](deploy/skywalking-9.7.0-es/README.md)                   | SkyWalking OAP / UI 9.7.0 + ES 7.14.1    | 11800、12800、18080、9200、9300   | 链路追踪，ES 存储                                      |
| [`deploy/skywalking-9.7.0-mysql`](deploy/skywalking-9.7.0-mysql/README.md)             | SkyWalking OAP / UI 9.7.0 + MySQL 8.0    | 11800、12800、18080、3308         | 链路追踪，MySQL 存储                                   |
| [`deploy/skywalking-9.7.0-agent`](deploy/skywalking-9.7.0-agent/README.md)          | SkyWalking Java Agent 9.1.0              | -                                 | 应用接入 agent 包（OSS 下载，无编排）                |
| [`deploy/skywalking-10.0.1-es`](deploy/skywalking-10.0.1-es/README.md)                 | SkyWalking OAP / UI 10.0.1 + ES 7.14.1   | 11800、12800、18080、9200、9300   | 链路追踪，ES 存储                                      |
| [`deploy/skywalking-10.0.1-mysql`](deploy/skywalking-10.0.1-mysql/README.md)           | SkyWalking OAP / UI 10.0.1 + MySQL 8.0   | 11800、12800、18080、3308         | 链路追踪，MySQL 存储                                   |
| [`deploy/skywalking-10.0.1-agent`](deploy/skywalking-10.0.1-agent/README.md)        | SkyWalking Java Agent 9.3.0              | -                                 | 应用接入 agent 包（OSS 下载，无编排）                |

同版本的 ES / MySQL / Agent 三种形态目录并列，按需选择其一部署；ES 形态与 MySQL 形态端口相同，不要同时启动。

### 构建示例

| 目录                                        | 基础镜像                           | 端口          | 说明                                                       |
| ------------------------------------------- | ---------------------------------- | ------------- | ---------------------------------------------------------- |
| [`demo/dotnet6`](demo/dotnet6/README.md)    | `compile-dotnet6` / `runtime-dotnet6` | 8080       | .NET 6 两阶段构建示例                                      |
| [`demo/dotnet8`](demo/dotnet8/README.md)    | `compile-dotnet8` / `runtime-dotnet8` | 8081       | .NET 8 两阶段构建示例                                      |
| [`demo/dotnet9`](demo/dotnet9/README.md)    | `compile-dotnet9` / `runtime-dotnet9` | 8082       | .NET 9 两阶段构建示例                                      |
| [`demo/python310-flask`](demo/python310-flask/README.md) | `runtime-python310` | 8083 | Python 3.10 + Flask 3.0 单阶段构建示例            |
| [`demo/tengine3`](demo/tengine3/README.md)     | `proxy-tengine3`                   | 80、443       | Tengine 3.1.0 反向代理示例，证书与站点配置挂载目录         |


# 支持的语言
- dotnet 适用于 dotnet 应用
  - 编译：`runtime-dotnet*` 之上的 `compile-dotnet*`
  - 运行：`runtime-dotnet*`
- java 适用于 java 应用
  - 编译与运行：`runtime-jdk*`（含 JDK，可直接编译后运行）
- python 适用于 python 应用
  - 编译与运行：`runtime-python310`（已配置 pip 镜像源）

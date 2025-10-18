# 目录索引

- [README](../README.md)：结构说明、镜像与部署编排总表
- 镜像仓库：`registry.cn-shanghai.aliyuncs.com/odboy/`

## 自建镜像 `image`

目录名即镜像 tag，镜像全名 `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:<目录名>`。
构建：`cd image/<目录> && sh build.sh`。

| 目录                                                      | Dockerfile                                                                        | 说明                                                                                     |
| --------------------------------------------------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| [alinux3-update20261111](../image/alinux3-update20261111) | [`alinux3-update20261111/Dockerfile`](../image/alinux3-update20261111/Dockerfile) | 系统基础镜像（alinux3 3.13.3），其余镜像均基于它                                         |
| [runtime-jdk11](../image/runtime-jdk11)                   | [`runtime-jdk11/Dockerfile`](../image/runtime-jdk11/Dockerfile)                   | JDK 11 运行环境                                                                          |
| [runtime-jdk17](../image/runtime-jdk17)                   | [`runtime-jdk17/Dockerfile`](../image/runtime-jdk17/Dockerfile)                   | JDK 17 运行环境                                                                          |
| [runtime-jdk21](../image/runtime-jdk21)                   | [`runtime-jdk21/Dockerfile`](../image/runtime-jdk21/Dockerfile)                   | JDK 21.0.2 运行环境                                                                      |
| [runtime-python3](../image/runtime-python3)               | [`runtime-python3/Dockerfile`](../image/runtime-python3/Dockerfile)               | Python 3.10.0 运行环境（含 `pip.conf` 镜像源）                                           |
| [runtime-dotnet6](../image/runtime-dotnet6)               | [`runtime-dotnet6/Dockerfile`](../image/runtime-dotnet6/Dockerfile)               | ASP.NET Core 运行时 6.0.35                                                               |
| [runtime-dotnet8](../image/runtime-dotnet8)               | [`runtime-dotnet8/Dockerfile`](../image/runtime-dotnet8/Dockerfile)               | ASP.NET Core 运行时 8.0.x                                                                |
| [runtime-dotnet9](../image/runtime-dotnet9)               | [`runtime-dotnet9/Dockerfile`](../image/runtime-dotnet9/Dockerfile)               | ASP.NET Core 运行时 9.0.x                                                                |
| [compile-dotnet6](../image/compile-dotnet6)               | [`compile-dotnet6/Dockerfile`](../image/compile-dotnet6/Dockerfile)               | .NET SDK 6.0.427 编译环境，两阶段构建示例见 [demo](../image/compile-dotnet6/demo/run.md) |
| [compile-dotnet8](../image/compile-dotnet8)               | [`compile-dotnet8/Dockerfile`](../image/compile-dotnet8/Dockerfile)               | .NET SDK 8.0.403 编译环境                                                                |
| [compile-dotnet9](../image/compile-dotnet9)               | [`compile-dotnet9/Dockerfile`](../image/compile-dotnet9/Dockerfile)               | .NET SDK 9.0.100-rc.2 编译环境                                                           |
| [proxy-tengine3](../image/proxy-tengine3)                 | [`proxy-tengine3/Dockerfile`](../image/proxy-tengine3/Dockerfile)                 | Tengine 3.1.0 源码编译（反代 / Web 服务器）                                              |
| [tools-ansible](../image/tools-ansible)                   | [`tools-ansible/Dockerfile`](../image/tools-ansible/Dockerfile)                   | Python 3.10.0 + Ansible 运维工具镜像                                                     |

## 部署编排 `app`

部署：`cd app/<目录>` 后 `sh install.sh`（启动）/ `sh shutdown.sh`（停止）。

| 组件        | 版本 / 形态                       | 目录                                                                         | 文档                                        |
| ----------- | --------------------------------- | ---------------------------------------------------------------------------- | ------------------------------------------- |
| Nacos       | 2.5.0 单机（MySQL 存储）          | [`nacos-2.5.0-standalone`](../app/nacos-2.5.0-standalone/run.md)             | [说明](../app/nacos-2.5.0-standalone)       |
| Nacos       | 2.5.0 三节点集群（MySQL 存储）    | [`nacos-2.5.0-cluster`](../app/nacos-2.5.0-cluster/run.md)                   | [说明](../app/nacos-2.5.0-cluster)          |
| Dubbo Admin | 0.6.0 单机（Zookeeper 3.9.3）     | [`dubbo-admin-0.6.0-standalone`](../app/dubbo-admin-0.6.0-standalone/run.md) | [说明](../app/dubbo-admin-0.6.0-standalone) |
| Dubbo Admin | 0.6.0 + Zookeeper 3.9.3 集群      | [`dubbo-admin-0.6.0-cluster`](../app/dubbo-admin-0.6.0-cluster/run.md)       | [说明](../app/dubbo-admin-0.6.0-cluster)    |
| Zookeeper   | 3.8.4 单机                        | [`zookeeper-3.8.4-standalone`](../app/zookeeper-3.8.4-standalone/run.md)     | [说明](../app/zookeeper-3.8.4-standalone)   |
| Zookeeper   | 3.8.4 三节点集群                  | [`zookeeper-3.8.4-cluster`](../app/zookeeper-3.8.4-cluster/run.md)           | [说明](../app/zookeeper-3.8.4-cluster)      |
| Zookeeper   | 3.9.3 单机                        | [`zookeeper-3.9.3-standalone`](../app/zookeeper-3.9.3-standalone/run.md)     | [说明](../app/zookeeper-3.9.3-standalone)   |
| Zookeeper   | 3.9.3 三节点集群                  | [`zookeeper-3.9.3-cluster`](../app/zookeeper-3.9.3-cluster/run.md)           | [说明](../app/zookeeper-3.9.3-cluster)      |
| RocketMQ    | 4.9.6 单机                        | [`rocketmq-4.9.6-standalone`](../app/rocketmq-4.9.6-standalone/run.md)       | [说明](../app/rocketmq-4.9.6-standalone)    |
| RocketMQ    | 4.9.6 单集群 1 主 2 从            | [`rocketmq-4.9.6-cluster-1m2s`](../app/rocketmq-4.9.6-cluster-1m2s/run.md)   | [说明](../app/rocketmq-4.9.6-cluster-1m2s)  |
| RocketMQ    | 4.9.6 双主                        | [`rocketmq-4.9.6-cluster-2m`](../app/rocketmq-4.9.6-cluster-2m/run.md)       | [说明](../app/rocketmq-4.9.6-cluster-2m)    |
| EFK         | ES / Kibana / Filebeat 7.14.1     | [`efk`](../app/efk/run.md)                                                   | [说明](../app/efk)                          |
| SkyWalking  | 9.5.0 + ES 7.14.1                 | [`skywalking-9.5.0-es`](../app/skywalking-9.5.0-es/run.md)                   | [说明](../app/skywalking-9.5.0-es)          |
| SkyWalking  | 9.5.0 + MySQL 8.0                 | [`skywalking-9.5.0-mysql`](../app/skywalking-9.5.0-mysql/run.md)             | [说明](../app/skywalking-9.5.0-mysql)       |
| SkyWalking  | 9.5.0 接入端（Java Agent 8.15.0） | [`skywalking-9.5.0-agent`](../app/skywalking-9.5.0-agent/README.md)          | [说明](../app/skywalking-9.5.0-agent)       |
| SkyWalking  | 9.7.0 + ES 7.14.1                 | [`skywalking-9.7.0-es`](../app/skywalking-9.7.0-es/run.md)                   | [说明](../app/skywalking-9.7.0-es)          |
| SkyWalking  | 9.7.0 + MySQL 8.0                 | [`skywalking-9.7.0-mysql`](../app/skywalking-9.7.0-mysql/run.md)             | [说明](../app/skywalking-9.7.0-mysql)       |
| SkyWalking  | 9.7.0 接入端（Java Agent 9.1.0）  | [`skywalking-9.7.0-agent`](../app/skywalking-9.7.0-agent/README.md)          | [说明](../app/skywalking-9.7.0-agent)       |
| SkyWalking  | 10.0.1 + ES 7.14.1                | [`skywalking-10.0.1-es`](../app/skywalking-10.0.1-es/run.md)                 | [说明](../app/skywalking-10.0.1-es)         |
| SkyWalking  | 10.0.1 + MySQL 8.0                | [`skywalking-10.0.1-mysql`](../app/skywalking-10.0.1-mysql/run.md)           | [说明](../app/skywalking-10.0.1-mysql)      |
| SkyWalking  | 10.0.1 接入端（Java Agent 9.3.0） | [`skywalking-10.0.1-agent`](../app/skywalking-10.0.1-agent/README.md)        | [说明](../app/skywalking-10.0.1-agent)      |
| Tengine     | 3.1.0 反代示例                    | [`tengine-3.1.0`](../app/tengine-3.1.0/run.md)                               | [说明](../app/tengine-3.1.0)                |

同版本的 ES / MySQL / Agent 三种形态目录并列，按需选择其一部署；ES 形态与 MySQL 形态端口相同，不要同时启动。

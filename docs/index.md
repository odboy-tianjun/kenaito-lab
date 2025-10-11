# 目录索引

- [README](../README.md)：结构说明、镜像与部署编排总表
- 镜像仓库：`registry.cn-shanghai.aliyuncs.com/odboy/`

## 自建镜像 `top/image`

目录名即镜像 tag，镜像全名 `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:<目录名>`。
构建：`cd top/image/<目录> && sh build.sh`。

| 目录                                                                     | 说明                                           |
|------------------------------------------------------------------------|----------------------------------------------|
| [alinux3-update20261111](../top/image/alinux3-update20261111)          | 系统基础镜像（alinux3 3.13.3），其余镜像均基于它              |
| [runtime-jdk11](../top/image/runtime-jdk11)                            | JDK 11 运行环境                                 |
| [runtime-jdk17](../top/image/runtime-jdk17)                            | JDK 17 运行环境                                 |
| [runtime-jdk21](../top/image/runtime-jdk21)                            | JDK 21.0.2 运行环境                             |
| [runtime-python3](../top/image/runtime-python3)                        | Python 3.10.0 运行环境（含 `pip.conf` 镜像源）        |
| [runtime-dotnet6](../top/image/runtime-dotnet6)                        | ASP.NET Core 运行时 6.0.35                     |
| [runtime-dotnet8](../top/image/runtime-dotnet8)                        | ASP.NET Core 运行时 8.0.x                      |
| [runtime-dotnet9](../top/image/runtime-dotnet9)                        | ASP.NET Core 运行时 9.0.x                      |
| [compile-dotnet6](../top/image/compile-dotnet6)                         | .NET SDK 6.0.427 编译环境，两阶段构建示例见 [demo](../top/image/compile-dotnet6/demo/run.md) |
| [compile-dotnet8](../top/image/compile-dotnet8)                        | .NET SDK 8.0.403 编译环境                       |
| [compile-dotnet9](../top/image/compile-dotnet9)                        | .NET SDK 9.0.100-rc.2 编译环境                 |
| [proxy-tengine3](../top/image/proxy-tengine3)                          | Tengine 3.1.0 源码编译（反代 / Web 服务器）             |
| [tools-ansible](../top/image/tools-ansible)                            | Python 3.10.0 + Ansible 运维工具镜像              |

## 部署编排 `top/app`

部署：`cd top/app/<目录>` 后 `sh install.sh`（启动）/ `sh shutdown.sh`（停止）。

| 组件         | 版本 / 形态                     | 目录（`run.md` 为部署说明）                                                                                       |
|------------|-----------------------------|---------------------------------------------------------------------------------------------------------|
| Nacos      | 2.5.0 单机（MySQL 存储）          | [nacos-2.5.0-standalone](../top/app/nacos-2.5.0-standalone/run.md)                                      |
| Nacos      | 2.5.0 三节点集群（MySQL 存储）       | [nacos-2.5.0-cluster](../top/app/nacos-2.5.0-cluster/run.md)                                            |
| Dubbo Admin | 0.6.0 单机（Zookeeper 3.9.3）   | [dubbo-admin-0.6.0-standalone](../top/app/dubbo-admin-0.6.0-standalone/run.md)                          |
| Dubbo Admin | 0.6.0 + Zookeeper 3.9.3 集群  | [dubbo-admin-0.6.0-cluster](../top/app/dubbo-admin-0.6.0-cluster/run.md)                                |
| Zookeeper  | 3.8.4 单机                    | [zookeeper-3.8.4-standalone](../top/app/zookeeper-3.8.4-standalone/run.md)                              |
| Zookeeper  | 3.8.4 三节点集群                | [zookeeper-3.8.4-cluster](../top/app/zookeeper-3.8.4-cluster/run.md)                                    |
| Zookeeper  | 3.9.3 单机                    | [zookeeper-3.9.3-standalone](../top/app/zookeeper-3.9.3-standalone/run.md)                              |
| Zookeeper  | 3.9.3 三节点集群                | [zookeeper-3.9.3-cluster](../top/app/zookeeper-3.9.3-cluster/run.md)                                    |
| RocketMQ   | 4.9.6 单机                    | [rocketmq-4.9.6-standalone](../top/app/rocketmq-4.9.6-standalone/run.md)                                |
| RocketMQ   | 4.9.6 单集群 1 主 2 从           | [rocketmq-4.9.6-cluster-1m2s](../top/app/rocketmq-4.9.6-cluster-1m2s/run.md)                            |
| RocketMQ   | 4.9.6 双主                    | [rocketmq-4.9.6-cluster-2m](../top/app/rocketmq-4.9.6-cluster-2m/run.md)                                |
| EFK        | ES / Kibana / Filebeat 7.14.1 | [efk](../top/app/efk/run.md)                                                                            |
| SkyWalking | 9.5.0 + ES 7.14.1           | [skywalking-9.5.0-es](../top/app/skywalking-9.5.0-es/run.md)                                            |
| SkyWalking | 9.5.0 + MySQL 8.0           | [skywalking-9.5.0-mysql](../top/app/skywalking-9.5.0-mysql/run.md)                                      |
| SkyWalking | 9.5.0 接入端（Java Agent 8.15.0） | [skywalking-9.5.0-agent](../top/app/skywalking-9.5.0-agent)                                             |
| SkyWalking | 9.7.0 + ES 7.14.1           | [skywalking-9.7.0-es](../top/app/skywalking-9.7.0-es/run.md)                                            |
| SkyWalking | 9.7.0 + MySQL 8.0           | [skywalking-9.7.0-mysql](../top/app/skywalking-9.7.0-mysql/run.md)                                      |
| SkyWalking | 9.7.0 接入端（Java Agent 9.1.0）  | [skywalking-9.7.0-agent](../top/app/skywalking-9.7.0-agent)                                             |
| SkyWalking | 10.0.1 + ES 7.14.1          | [skywalking-10.0.1-es](../top/app/skywalking-10.0.1-es/run.md)                                          |
| SkyWalking | 10.0.1 + MySQL 8.0          | [skywalking-10.0.1-mysql](../top/app/skywalking-10.0.1-mysql/run.md)                                    |
| SkyWalking | 10.0.1 接入端（Java Agent 9.3.0） | [skywalking-10.0.1-agent](../top/app/skywalking-10.0.1-agent)                                           |
| Tengine    | 3.1.0 反代示例                  | [tengine-3.1.0](../top/app/tengine-3.1.0/run.md)                                                        |

同版本的 ES / MySQL / Agent 三种形态目录并列，按需选择其一部署；ES 形态与 MySQL 形态端口相同，不要同时启动。

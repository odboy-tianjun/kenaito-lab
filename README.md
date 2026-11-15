# dockerfiles

应用环境镜像定制（alinux3）与中间件部署编排。镜像仓库：`registry.cn-shanghai.aliyuncs.com/odboy/`

```
image/  自建镜像：每个目录 = Dockerfile + build.sh，目录名即镜像 tag
deploy/ 部署编排：三方镜像 + 自研的 docker-compose / 配置，每个目录 = docker-compose.yml + startup.sh / shutdown.sh + README.md(+demo.png)
demo/app/          构建示例：基于 image/ 下的镜像做构建与运行演示（dotnet6/8/9、python310-flask、springboot-jar17、spring-war17、
                   go、rust、node-backend，以及 node-frontend-vue2/vue3/vite5 与 react-function/react-class 前端，均为两阶段构建）
demo/plateform/    平台类示例（tengine3 反向代理）
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
| `image/runtime-jdk25`          | `kenaito:runtime-jdk25`          | 上者 / JDK 25.0.2                 | 运行环境，仅 JDK；编 Java 25 目标时作为 `compile-maven3-jdk25` 的基础镜像 |
| `image/runtime-python310`      | `kenaito:runtime-python310`      | 上者 / Python 3.10.0              | 运行环境，Python + pip 源（`pip.conf`）                                  |
| `image/runtime-python315`      | `kenaito:runtime-python315`      | 上者 / Python 3.15.2              | 运行环境，Python + pip 源（`pip.conf`）；node / ansible 镜像均基于它     |
| `image/runtime-tomcat10`       | `kenaito:runtime-tomcat10`       | `runtime-jdk17` / Tomcat 10.1.34  | 运行环境，JDK 17 + Tomcat（war 包部署用），兼容 Spring 6 |
| `image/runtime-dotnet6`        | `kenaito:runtime-dotnet6`        | 上者 / ASP.NET Core 运行时 6.0.35 | 运行环境，仅运行时                                                       |
| `image/runtime-dotnet8`        | `kenaito:runtime-dotnet8`        | 上者 / ASP.NET Core 运行时 8.0.x  | 运行环境，仅运行时                                                       |
| `image/runtime-dotnet9`        | `kenaito:runtime-dotnet9`        | 上者 / ASP.NET Core 运行时 9.0.x  | 运行环境，仅运行时                                                       |
| `image/compile-dotnet6`        | `kenaito:compile-dotnet6`        | 上者 / .NET SDK 6.0.427           | 编译环境（SDK + 编译工具链），两阶段构建示例见 `demo/app/dotnet6` |
| `image/compile-dotnet8`        | `kenaito:compile-dotnet8`        | 上者 / .NET SDK 8.0.403           | 编译环境（SDK + 编译工具链），两阶段构建示例见 `demo/app/dotnet8` |
| `image/compile-dotnet9`        | `kenaito:compile-dotnet9`        | 上者 / .NET SDK 9.0.100-rc.2      | 编译环境（SDK + 编译工具链），两阶段构建示例见 `demo/app/dotnet9` |
| `image/compile-maven3-jdk17`   | `kenaito:compile-maven3-jdk17`   | `runtime-jdk17` / Maven 3.9.9     | 编译环境（JDK 17 + Maven + git/gcc/make），`settings.xml` 走阿里云源 |
| `image/compile-maven3-jdk21`   | `kenaito:compile-maven3-jdk21`   | `runtime-jdk21` / Maven 3.9.9     | 同上，JDK 换 21；编 Java 21 目标时用 |
| `image/compile-maven3-jdk25`   | `kenaito:compile-maven3-jdk25`   | `runtime-jdk25` / Maven 3.9.9     | 同上，JDK 换 25；编 Java 25 目标时用 |
| `image/proxy-tengine3`         | `kenaito:proxy-tengine3`         | `system-alinux3` / Tengine 3.1.0 源码编译 | 反向代理 / Web 服务器，自定义 `nginx.conf`                               |
| `image/tools-ansible`          | `kenaito:ansible`                | `runtime-python315` / Ansible     | 运维工具镜像，锁定 ansible-core 2.16.3                     |
| `image/runtime-go123`          | `kenaito:runtime-go123`          | 上者 / Go 1.23.12                 | 运行环境，Go + git/gcc（cgo）                                            |
| `image/runtime-go122`          | `kenaito:runtime-go122`          | 上者 / Go 1.22.12                 | 同上，Go 1.22 版本线                                                     |
| `image/compile-go123`          | `kenaito:compile-go123`          | `runtime-go123` / 编译工具链      | 编译环境，追加 make/gcc-c++/pkg-config，`GOPROXY=goproxy.cn`             |
| `image/compile-go122`          | `kenaito:compile-go122`          | `runtime-go122` / 编译工具链      | 同上，Go 1.22 版本线                                                     |
| `image/runtime-node22`         | `kenaito:runtime-node22`         | `runtime-python315` / Node 22.23.5 | 运行环境，Node + npm（python3 供原生模块使用）                         |
| `image/runtime-node26`         | `kenaito:runtime-node26`         | `runtime-python315` / Node 26.13.1 | 运行环境，Node 当前最新版本线                                           |
| `image/runtime-node20`         | `kenaito:runtime-node20`         | `runtime-python315` / Node 20.20.2 | 运行环境，Node 20 版本线                                               |
| `image/runtime-node18`         | `kenaito:runtime-node18`         | `runtime-python315` / Node 18.20.8 | 运行环境，Node 18 版本线                                               |
| `image/runtime-node16`         | `kenaito:runtime-node16`         | `runtime-python315` / Node 16.20.2 | 运行环境，Node 16 版本线                                               |
| `image/compile-node22`         | `kenaito:compile-node22`         | `runtime-node22` / 编译工具链     | 编译环境，python3/make/gcc/gcc-c++（node-gyp），npm 源走 npmmirror       |
| `image/compile-node26`         | `kenaito:compile-node26`         | `runtime-node26` / 编译工具链     | 同上，Node 最新版本线                                                    |
| `image/compile-node20`         | `kenaito:compile-node20`         | `runtime-node20` / 编译工具链     | 同上，Node 20 版本线                                                     |
| `image/compile-node18`         | `kenaito:compile-node18`         | `runtime-node18` / 编译工具链     | 同上，Node 18 版本线                                                     |
| `image/compile-node16`         | `kenaito:compile-node16`         | `runtime-node16` / 编译工具链     | 同上，Node 16 版本线                                                     |
| `image/runtime-rust`           | `kenaito:runtime-rust`           | 上者 / Rust 1.100.0               | 运行环境，rustc/cargo（无文档、无 rust-src）                             |
| `image/compile-rust`           | `kenaito:compile-rust`           | `runtime-rust` / 编译工具链       | 编译环境，追加 gcc/make/pkg-config/openssl-devel，crates 源走阿里云       |
| `image/compile-android-gradle8x` | `kenaito:compile-android-gradle8x` | `runtime-jdk21` / SDK 35+36、build-tools 35.0.0、NDK 27、Gradle 8.14.3 | Android 编译环境，仅出 apk/aar（无运行阶段），Gradle 仓库源走阿里云；示例见 `demo/app/android-kotlin`、`demo/app/android-java` |

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
| [`deploy/rocketmq-4.9.7-standalone`](deploy/rocketmq-4.9.7-standalone/README.md)       | RocketMQ 4.9.7 + Dashboard 2.1.0         | 9876、10909-10912                 | 单 Namesrv + 单 Broker                                 |
| [`deploy/rocketmq-4.9.7-cluster-1m2s`](deploy/rocketmq-4.9.7-cluster-1m2s/README.md)   | RocketMQ 4.9.7 + Dashboard 2.1.0         | 9876、10909-10912                 | 单 Master + 双 Slave                                   |
| [`deploy/rocketmq-4.9.7-cluster-2m`](deploy/rocketmq-4.9.7-cluster-2m/README.md)       | RocketMQ 4.9.7 + Dashboard 2.1.0          | 9876、10709-10712                 | 双 Master（无 Slave）                                  |
| [`deploy/rocketmq-5.5.0-standalone`](deploy/rocketmq-5.5.0-standalone/README.md)       | RocketMQ 5.5.0 + Dashboard 2.1.0          | 9876、10909-10912                 | 单 Namesrv + 单 Broker                                 |
| [`deploy/rocketmq-5.5.0-cluster-1m2s`](deploy/rocketmq-5.5.0-cluster-1m2s/README.md)   | RocketMQ 5.5.0 + Dashboard 2.1.0          | 9876、10909-10912                 | 单 Master + 双 Slave                                   |
| [`deploy/rocketmq-5.5.0-cluster-2m`](deploy/rocketmq-5.5.0-cluster-2m/README.md)       | RocketMQ 5.5.0 + Dashboard 2.1.0          | 9876、10709-10712                 | 双 Master（无 Slave）                                  |
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
| [`demo/app/dotnet6`](demo/app/dotnet6/README.md)    | `compile-dotnet6` / `runtime-dotnet6` | 8080       | .NET 6 两阶段构建示例                                      |
| [`demo/app/dotnet8`](demo/app/dotnet8/README.md)    | `compile-dotnet8` / `runtime-dotnet8` | 8081       | .NET 8 两阶段构建示例                                      |
| [`demo/app/dotnet9`](demo/app/dotnet9/README.md)    | `compile-dotnet9` / `runtime-dotnet9` | 8082       | .NET 9 两阶段构建示例                                      |
| [`demo/app/python310-flask`](demo/app/python310-flask/README.md) | `runtime-python310` | 8083 | Python 3.10 + Flask 3.0 单阶段构建示例            |
| [`demo/app/springboot-jar17`](demo/app/springboot-jar17/README.md) | `compile-maven3-jdk17` / `runtime-jdk17` | 8084 | Spring Boot 3.4 可执行 jar 两阶段构建示例 |
| [`demo/app/spring-war17`](demo/app/spring-war17/README.md)       | `compile-maven3-jdk17` / `runtime-tomcat10` | 8085 | Spring MVC 6 war 包 + 外置 Tomcat 10.1 两阶段构建示例 |
| [`demo/app/go`](demo/app/go/README.md)             | `compile-go123` / `runtime-go123`  | 8086       | Go 1.23 标准库 Web 两阶段构建示例                           |
| [`demo/app/node-backend`](demo/app/node-backend/README.md) | `compile-node22` / `runtime-node22` | 8087 | Node 22 内置 http 模块后端服务两阶段构建示例          |
| [`demo/app/node-frontend-vue2`](demo/app/node-frontend-vue2/README.md) | `compile-node22` / `proxy-tengine3` | 8089 | Vue 2 + Element UI 2 前端，Tengine 托管静态文件 |
| [`demo/app/node-frontend-vue3`](demo/app/node-frontend-vue3/README.md) | `compile-node22` / `proxy-tengine3` | 8090 | Vue 3 + Element Plus 前端 |
| [`demo/app/node-frontend-react-function`](demo/app/node-frontend-react-function/README.md) | `compile-node22` / `proxy-tengine3` | 8091 | React 19 函数组件 + Hooks 写法 |
| [`demo/app/node-frontend-react-class`](demo/app/node-frontend-react-class/README.md) | `compile-node22` / `proxy-tengine3` | 8093 | React 19 类组件写法 |
| [`demo/app/node-frontend-vite5`](demo/app/node-frontend-vite5/README.md) | `compile-node22` / `proxy-tengine3` | 8092 | Vite 5 + Vue 3 前端，用于和 Vite 7 对照 |
| [`demo/app/rust`](demo/app/rust/README.md)         | `compile-rust` / `runtime-rust`    | 8088       | Rust 标准库 TcpListener Web 两阶段构建示例                  |
| [`demo/app/android-kotlin`](demo/app/android-kotlin/README.md) | `compile-android-gradle8x` | - | Kotlin Android 应用编译示例，产出 debug apk 并拷回宿主机（apk 由真机安装，无运行阶段） |
| [`demo/app/android-java`](demo/app/android-java/README.md)     | `compile-android-gradle8x` | - | 纯 Java Android 应用编译示例，产出 debug apk 并拷回宿主机 |
| [`demo/plateform/tengine3`](demo/plateform/tengine3/README.md)     | `proxy-tengine3`                   | 80、443       | Tengine 3.1.0 反向代理示例，证书与站点配置挂载目录         |


# 支持的语言
- dotnet 适用于 dotnet 应用
  - 编译：`runtime-dotnet*` 之上的 `compile-dotnet*`
  - 运行：`runtime-dotnet*`
- java 适用于 java 应用
  - 编译：`compile-maven3-jdk17` / `-jdk21` / `-jdk25`（JDK + Maven，按目标字节码版本选）
  - 运行：`runtime-jdk*`（仅 JDK，直接 `java -jar` 或作为外置 Tomcat 的基础镜像）
  - war 包运行：`runtime-tomcat10`（JDK 17 + Tomcat 10.1，兼容 Spring 6 / Servlet 6）
- python 适用于 python 应用
  - 编译与运行：`runtime-python310`（已配置 pip 镜像源）；另有 `runtime-python315` 作为 node / ansible 镜像的基础，不单独用于示例
- go 适用于 go 应用
  - 编译：`compile-go123` / `compile-go122`（Go 工具链 + gcc，`GOPROXY=goproxy.cn`）
  - 运行：`runtime-go123` / `runtime-go122`（仅 Go，直接运行静态编译的二进制即可）
- node 适用于 node 应用
  - 编译：`compile-node26` / `compile-node22` / `compile-node20` / `compile-node18` / `compile-node16`（npm 源 npmmirror，python3 继承自 runtime-python315，另装 gcc）
  - 运行：`runtime-node26` / `runtime-node22` / `runtime-node20` / `runtime-node18` / `runtime-node16`（仅 Node，`node server.js`）
- rust 适用于 rust 应用
  - 编译：`compile-rust`（rustc/cargo + gcc/make，crates 源走阿里云）
  - 运行：`runtime-rust`（rustc/cargo，直接运行编译出的二进制）
- android 适用于 android 应用（kotlin / java）
  - 编译：`compile-android-gradle8x`（JDK 21 + Android SDK 35/36 + build-tools 35.0.0 + NDK 27 + Gradle 8.14.3，Gradle 仓库源走阿里云）
  - 运行：不适用。产物是 apk / aar，由真机或模拟器安装，容器里没有常驻进程
  - 取产物：`docker create` + `docker cp`，或直接把源码目录挂载进编译镜像跑 `gradle`，示例见 `demo/app/android-kotlin`、`demo/app/android-java`

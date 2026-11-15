# springboot-jar17 示例

演示如何用 `compile-maven3-jdk17` + `runtime-jdk17` 两阶段构建并运行一个 Spring Boot 3 Web 应用，产物是**可执行 jar**（内嵌 Tomcat）。

| 阶段 | 镜像 | 说明 |
| --- | --- | --- |
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-maven3-jdk17` | JDK 17 + Maven 3.9.9 + 阿里云 Maven 源（见 `image/compile-maven3-jdk17`） |
| 运行 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-jdk17` | 仅 JDK 17（见 `image/runtime-jdk17`） |

运行阶段只拷贝 `spring-boot-maven-plugin` 重打包后的 jar，镜像里不含 Maven、源码和 `~/.m2`。

### 示例内容

```
springboot-jar17/
├── pom.xml                         # Spring Boot 3.4.1，Java 17，parent 统一管版本
├── src/main/java/cn/odboy/demo/
│   ├── DemoApplication.java        # @SpringBootApplication 入口
│   ├── DemoController.java         # @RestController：/ 、/api/info、/api/hello/{name}
│   └── PageController.java         # @Controller：/page 渲染 Thymeleaf 模板
├── src/main/resources/
│   ├── application.yml             # 端口 8084、优雅停机、actuator 只开 health
│   └── templates/index.html        # /page 页面
├── Dockerfile                      # 两阶段：compile-maven3-jdk17 -> runtime-jdk17
├── build.sh                        # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml              # 部署编排（端口 8084，固定 IP 172.30.1.20）
├── startup.sh                      # docker-compose up -d
└── shutdown.sh                     # docker-compose down
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-springboot-jar17 .
PUSH=1 sh build.sh     # 构建并推送
sh startup.sh          # docker-compose -f docker-compose.yml -p springboot-jar17-demo up -d
```

访问：

```shell
curl http://127.0.0.1:8084/                 # {"message":"springboot-jar17 is running","java":"17.0.x",...}
curl http://127.0.0.1:8084/api/info         # 同上，等价入口
curl http://127.0.0.1:8084/api/hello/demo   # {"message":"Hello, demo!","time":"..."}
curl http://127.0.0.1:8084/actuator/health  # {"status":"UP"}
```

浏览器打开 http://127.0.0.1:8084/page 可看到渲染后的运行信息页面。

### 关键点

**依赖层缓存**：先只 `COPY pom.xml` 执行 `mvn dependency:go-offline`，再 `COPY src` 编译。只改源码时不会重新下载依赖；
镜像源已在 `compile-maven3-jdk17` 的 `settings.xml` 里指向阿里云，无需额外换源。

**两阶段构建**：Maven 仓库、编译中间产物都留在 build 阶段，最终镜像只多一个 jar。这也是 `runtime-jdk*` 与 `compile-maven3-*` 分开的原因。

**监听地址**：容器内 8084（`server.port=${APP_PORT:8084}`），避开 dotnet6/8/9（8080-8082）、python310-flask（8083）、spring-war17（8085）。

**时区**：启动参数带 `-Duser.timezone=Asia/Shanghai`，compose 再声明 `TZ`；接口里额外按 UTC+8 输出时间，双保险。

**优雅停机**：`server.shutdown=graceful`，`ENTRYPOINT` 用 exec 形式，`docker stop` 的 SIGTERM 直接到 JVM。

**内存**：`-XX:MaxRAMPercentage=75.0` 让 JVM 按容器内存上限算堆；compose 里用 `JAVA_OPTS` 演示另一种覆盖方式（需自行在 Dockerfile 里接 `JAVA_OPTS`，本示例入口为固定数组）。

### 运维命令

```shell
docker logs -f springboot-jar17-demo              # 应用日志
docker exec springboot-jar17-demo java -version   # 确认 JDK 版本
docker exec springboot-jar17-demo sh -c 'ls -lh /home/admin'
```

### 调试时直接在编译镜像里运行

需要看编译报错或临时跑一下时，可以只挂载源码进编译镜像（Maven 依赖缓存在容器内 `~/.m2`）：

```shell
docker run --rm -it -p 8084:8084 -v "$PWD":/src -w /src \
  registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-maven3-jdk17 \
  mvn spring-boot:run
```

想把宿主机的 `~/.m2` 复用到构建里，也可以给 `build.sh` 的 `docker build` 加
`--build-arg`/`--mount=type=cache,target=/root/.m2` 之类的 BuildKit 缓存（本示例为简单起见未启用）。

### 停止

```shell
sh shutdown.sh
```

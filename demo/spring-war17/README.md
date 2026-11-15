# spring-war17 示例

演示如何用 `compile-maven3-jdk17` 打出 **war 包**，再部署到外置 Tomcat 10.1 运行。与
[`demo/springboot-jar17`](../springboot-jar17/README.md) 对照：应用代码几乎一样，区别只在打包方式与运行容器。

| 阶段 | 镜像 | 说明 |
| --- | --- | --- |
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-maven3-jdk17` | JDK 17 + Maven 3.9.9 + 阿里云 Maven 源（见 `image/compile-maven3-jdk17`） |
| 运行 | `tomcat:10.1-jdk17-temurin`（Docker Hub 官方镜像） | Servlet 6.0 / Jakarta EE 10，自带 JDK 17 运行时；仓库内暂无自建 Tomcat 镜像 |

> Spring 6 要求 Jakarta EE 9+，即 **Tomcat 10.1 及以上**；Tomcat 9（`javax.servlet`）跑不了本示例。

### 示例内容

```
spring-war17/
├── pom.xml                         # packaging=war，Spring 6.2.1 + Thymeleaf 3.1，不依赖 Boot
├── src/main/java/cn/odboy/demo/
│   ├── WebAppInitializer.java      # 替代 web.xml，注册 DispatcherServlet（映射 /api/*）
│   ├── WebConfig.java              # @EnableWebMvc + Thymeleaf 视图解析 + Jackson
│   ├── DemoController.java         # @RestController：/ 、/info、/hello/{name}（在 /api 前缀下）
│   └── PageController.java         # @Controller：/api/page 渲染模板
├── src/main/resources/templates/index.html
├── src/main/webapp/WEB-INF/web.xml       # 仅声明 metadata-complete=false 与会话超时，无 servlet 映射
├── Dockerfile                      # 两阶段：compile-maven3-jdk17 -> tomcat:10.1-jdk17-temurin
├── build.sh                        # 构建镜像（PUSH=1 时同时推送）
├── docker-compose.yml              # 部署编排（8085 -> 容器 8080，固定 IP 172.30.2.20）
├── startup.sh                      # docker-compose up -d
└── shutdown.sh                     # docker-compose down
```

### 构建与部署

```shell
sh build.sh            # docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-spring-war17 .
PUSH=1 sh build.sh     # 构建并推送
sh startup.sh          # docker-compose -f docker-compose.yml -p spring-war17-demo up -d
```

war 部署后上下文路径为 **`/spring-war17`**，接口都在该前缀下：

```shell
curl http://127.0.0.1:8085/spring-war17/api/          # {"message":"spring-war17 is running","java":"17.0.x",...}
curl http://127.0.0.1:8085/spring-war17/api/info      # 同上
curl http://127.0.0.1:8085/spring-war17/api/hello/demo
```

浏览器打开 http://127.0.0.1:8085/spring-war17/api/page 可看到渲染后的运行信息页面。

### 关键点

**没有 servlet 映射的 web.xml**：`WebAppInitializer` 继承 `AbstractAnnotationConfigDispatcherServletInitializer`，
Tomcat 通过 Servlet 3+ 的 `ServletContainerInitializer` 机制自动发现它并注册 DispatcherServlet。
`src/main/webapp/WEB-INF/web.xml` 只声明 `metadata-complete="false"` 和会话超时，不写任何 servlet 映射；
`maven-war-plugin` 设置了 `failOnMissingWebXml=false`，即使删掉它也能打包。

**DispatcherServlet 只映射 `/api/*`**：`/api` 前缀外的请求仍由 Tomcat 默认 Servlet 处理（404 或欢迎页），
避免传统 war 里 DispatcherServlet 抢占 `/` 后静态资源失效。`web.xml` 式项目可以同样用 `<url-pattern>/api/*</url-pattern>`。

**context.xml**：`src/main/webapp/META-INF/context.xml` 只是占位文件，用来把该目录纳入构建上下文；
它不参与启动流程，删掉不影响运行。

**上下文路径**：war 文件名即上下文路径，`finalName` 固定为 `spring-war17`，所以是 `/spring-war17`。
想让应用直接挂在根路径 `/`，把 war 改名为 `ROOT.war` 即可。

**两阶段构建**：build 阶段在 `compile-maven3-jdk17` 里 `mvn package`，runtime 阶段只把 war 拷进官方 Tomcat 镜像，
运行镜像不含 Maven/源码。Tomcat 镜像保留官方默认布局，只清空自带 `webapps/*`。

**端口**：容器内 Tomcat 仍是 8080（官方镜像默认），宿主机映射到 8085。

**健康检查**：compose 用 `curl` 探测 `/spring-war17/api/info`，`start_period: 30s` 覆盖 war 解压与 Spring 初始化；
temurin 镜像自带 curl，无需额外安装。

### 运维命令

```shell
docker logs -f spring-war17-demo                        # catalina.out 日志
docker exec spring-war17-demo ls /usr/local/tomcat/webapps   # 查看已部署应用（war 与解包目录）
docker exec spring-war17-demo java -version             # 确认 JDK 版本
```

### 调试时直接在编译镜像里跑

```shell
docker run --rm -it -v "$PWD":/src -w /src \
  registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-maven3-jdk17 \
  mvn -B clean package
```

得到的 `target/spring-war17.war` 可以拷到任意 Tomcat 10.1 的 `webapps/` 下部署。

### 停止

```shell
sh shutdown.sh
```

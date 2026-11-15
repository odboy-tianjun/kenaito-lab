# 编译阶段：compile-maven3-jdk17（JDK 17 + Maven 3.9.9 + 阿里云 Maven 源）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-maven3-jdk17 AS build
WORKDIR /src

# 先只拷贝 POM 预热依赖层：源码改动不会让依赖缓存失效
COPY pom.xml ./
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests \
    && cp target/springboot-jar17.jar /src/app.jar

# 运行阶段：runtime-jdk17（仅 JDK，不含 Maven）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-jdk17 AS runtime
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV APP_PORT=8084
WORKDIR /home/admin
COPY --from=build /src/app.jar ./
EXPOSE 8084
# exec 形式，保证 docker stop 的 SIGTERM 能被 JVM 收到，触发 Spring 优雅停机
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-Duser.timezone=Asia/Shanghai", "-jar", "/home/admin/app.jar"]

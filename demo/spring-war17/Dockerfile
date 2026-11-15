# 编译阶段：compile-maven3-jdk17（JDK 17 + Maven 3.9.9 + 阿里云 Maven 源）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-maven3-jdk17 AS build
WORKDIR /src

# 先只拷贝 POM 预热依赖层：源码改动不会让依赖缓存失效
COPY pom.xml ./
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests

# 运行阶段：外置 Tomcat 10.1（Servlet 6.0 / Jakarta EE 10，对应 Spring 6），仅含 JDK 17 运行时
FROM tomcat:10.1-jdk17-temurin AS runtime
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
# 清掉官方镜像自带的 welcome 应用，只部署本示例
RUN rm -rf /usr/local/tomcat/webapps/* \
    && ln -snf /usr/share/zoneinfo/${TimeZone} /etc/localtime

# 带版本号的 war 改名后部署，上下文路径 = /spring-war17
COPY --from=build /src/target/spring-war17.war /usr/local/tomcat/webapps/spring-war17.war

EXPOSE 8080
# exec 形式：catalina.sh run 在前台运行，SIGTERM 可正常触发 Tomcat 优雅停机
ENTRYPOINT ["catalina.sh", "run"]

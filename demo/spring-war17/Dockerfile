# 编译阶段：compile-maven3-jdk17（JDK 17 + Maven 3.9.9 + 阿里云 Maven 源）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-maven3-jdk17 AS build
WORKDIR /src

# 先只拷贝 POM 预热依赖层：源码改动不会让依赖缓存失效
COPY pom.xml ./
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests

# 运行阶段：自建 runtime-tomcat10（runtime-jdk17 + Tomcat 10.1.34，Servlet 6.0 / Jakarta EE 10，对应 Spring 6）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-tomcat10 AS runtime
LABEL MAINTAINER="tianjun@odboy.cn"
WORKDIR /home/admin
# 带版本号的 war 改名后部署，上下文路径 = /spring-war17
# 基础镜像已清空 webapps/*，时区、curl、EXPOSE 8080、ENTRYPOINT catalina.sh run 均由基础镜像提供
COPY --from=build /src/target/spring-war17.war ${CATALINA_HOME}/webapps/spring-war17.war

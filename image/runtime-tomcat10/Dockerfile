FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-jdk17
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV CATALINA_HOME=/usr/local/tomcat
ENV CATALINA_BASE=/usr/local/tomcat
ENV PATH="${CATALINA_HOME}/bin:$PATH"
WORKDIR /home/admin
# https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz
# 由 build.sh 预先下载并校验 sha512 到本目录，ADD 直接解包得到 apache-tomcat-10.1.34/
ADD apache-tomcat-10.1.34.tar.gz /usr/local/
# curl 用于健康检查；nc 用于排障时探测端口
RUN set -e && yum install \
    curl \
    nmap-ncat \
    sysstat -y; \
    mv /usr/local/apache-tomcat-10.1.34 ${CATALINA_HOME}; \
    rm -rf ${CATALINA_HOME}/webapps/*; \
    chmod +x ${CATALINA_HOME}/bin/*.sh; \
    catalina.sh version;
EXPOSE 8080
# exec 形式：catalina.sh run 前台运行，docker stop 的 SIGTERM 可触发 Tomcat 优雅停机
ENTRYPOINT ["catalina.sh", "run"]

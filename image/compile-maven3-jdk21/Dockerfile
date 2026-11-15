FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-jdk21
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV MAVEN_HOME=/usr/local/maven3
ENV PATH="${MAVEN_HOME}/bin:$PATH"
WORKDIR /home/admin
# https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
# 由 build.sh 预先下载到本目录；bin.tar.gz 解包即为 apache-maven-3.9.9/
ADD apache-maven-3.9.9-bin.tar.gz /usr/local/
# make/gcc：编译含 jni/本地库的依赖；git：maven-scm / jgit 插件；
# sysstat/net-tools：排障；tar/wget 若基础镜像未带也一并装上
RUN set -e && yum install \
    make \
    gcc \
    git \
    tar \
    wget \
    sysstat \
    net-tools -y; \
    mv /usr/local/apache-maven-3.9.9 ${MAVEN_HOME}; \
    chmod +x ${MAVEN_HOME}/bin/*; \
    mvn -v;
# 阿里云 Maven 镜像（覆盖 central），构建时不依赖 repo1.maven.org 的公网速度
# 用 COPY 而非 ADD/ONBUILD：放在 Maven 安装之后，避免覆盖安装包自带的 conf/settings.xml
COPY settings.xml ${MAVEN_HOME}/conf/settings.xml

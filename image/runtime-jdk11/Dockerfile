FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:system-alinux3
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV JAVA_HOME=/usr/local/java
ENV PATH="${JAVA_HOME}/bin:$PATH"
WORKDIR /home/admin
ADD jdk-11.0.2.tar.gz ./
RUN yum install \
    tar \
    wget \
    net-tools  \
    bind-utils -y; \
    mv ./jdk-11.0.2 ${JAVA_HOME}; \
    chmod +x ${JAVA_HOME}/bin/*; \
    java -version;

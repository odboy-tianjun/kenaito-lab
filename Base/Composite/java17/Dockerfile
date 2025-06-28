FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:alinux3-update20261111
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV JAVA_HOME=/usr/local/java
ENV PATH="${JAVA_HOME}/bin:$PATH"
WORKDIR /home/admin
ADD jdk-17.0.2.tar.gz ./
RUN ln -snf /usr/share/zoneinfo/$TimeZone /etc/localtime && echo $TimeZone > /etc/timezone; \
    sed -i 's/mirrors.cloud.aliyuncs.com/mirrors.aliyun.com/' /etc/yum.repos.d/*.repo; \
    yum install \
    tar \
    wget \
    net-tools  \
    bind-utils -y; \
    mv ./jdk-17.0.2 ${JAVA_HOME}; \
    chmod +x ${JAVA_HOME}/bin/*; \
    java -version;

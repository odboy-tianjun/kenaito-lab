FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:system-alinux3
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV NODE_HOME=/usr/local/node
ENV PATH="${NODE_HOME}/bin:$PATH"
WORKDIR /home/admin
# https://mirrors.aliyun.com/nodejs-release/v26.13.1/node-v26.13.1-linux-x64.tar.gz（官方源 https://nodejs.org/dist/）
# 由 build.sh 预先下载到本目录；解包后即为 node-v26.13.1-linux-x64/ 目录
ADD node-v26.13.1-linux-x64.tar.gz /usr/local/
RUN set -e && yum install \
    libatomic \
    ca-certificates \
    sysstat \
    net-tools -y; \
    mv /usr/local/node-v26.13.1-linux-x64 ${NODE_HOME}; \
    chmod +x ${NODE_HOME}/bin/*; \
    node -v; \
    npm -v;

# 全局 npm 源走阿里云（npmmirror），与 runtime-python310 的 pip.conf 对应
COPY npmrc /root/.npmrc

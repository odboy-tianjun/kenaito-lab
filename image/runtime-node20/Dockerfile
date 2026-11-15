# 基于 python 运行时：Node 原生模块（node-gyp）需要 python3，直接复用现成镜像，避免重复装
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-python315
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV NODE_HOME=/usr/local/node
ENV PATH="${NODE_HOME}/bin:$PATH"
WORKDIR /home/admin
# https://mirrors.aliyun.com/nodejs-release/v20.20.2/node-v20.20.2-linux-x64.tar.gz（官方源 https://nodejs.org/dist/）
# 由 build.sh 预先下载到本目录；解包后即为 node-v20.20.2-linux-x64/ 目录
ADD node-v20.20.2-linux-x64.tar.gz /usr/local/
RUN set -e && yum install \
    libatomic \
    ca-certificates \
    sysstat \
    net-tools -y; \
    mv /usr/local/node-v20.20.2-linux-x64 ${NODE_HOME}; \
    chmod +x ${NODE_HOME}/bin/*; \
    node -v; \
    npm -v;

# 全局 npm 源走阿里云（npmmirror）：Node 发行包自带 npm 的全局配置目录就是
# ${NODE_HOME}/etc/npmrc（npm prefix 为 NODE_HOME 时），放在这里对所有用户生效
COPY npmrc ${NODE_HOME}/etc/npmrc

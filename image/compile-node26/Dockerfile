FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-node26
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
WORKDIR /home/admin
# npm 源由基础镜像的 /usr/local/node/etc/npmrc 统一指向阿里云，这里确认生效；
# corepack 已不在 Node 发行包内（npm 10+ 移出），需要 pnpm / yarn 时用 npm i -g 安装
RUN set -e && npm config get registry;
# node-gyp 的 python3 已由基础镜像（runtime-python315）提供；这里只补 gcc/gcc-c++/make 编 C/C++ 扩展
RUN set -e && yum install \
    make \
    gcc \
    gcc-c++ \
    git -y; \
    node -v; \
    npm -v;

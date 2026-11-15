FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:system-alinux3
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV GOROOT=/usr/local/go
ENV GOPATH=/home/admin/go
ENV PATH="${GOROOT}/bin:${GOPATH}/bin:$PATH"
WORKDIR /home/admin
# https://mirrors.aliyun.com/golang/go1.23.12.linux-amd64.tar.gz（官方源 https://go.dev/dl/）
# 由 build.sh 预先下载到本目录；解包后即为 go/ 目录
ADD go1.23.12.linux-amd64.tar.gz /usr/local/
# git：go get / go mod 拉取私有仓库；ca-certificates：https 访问模块代理；
# gcc：cgo 代码与部分依赖（如 sqlite、cgo 版 net）编译需要
RUN set -e && yum install \
    git \
    gcc \
    ca-certificates \
    sysstat \
    net-tools -y; \
    go version;

FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-go123
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
# 国内 Go 模块代理，go mod download / go build 不再直连 proxy.golang.org
ENV GOPROXY=https://goproxy.cn,direct
# GONOSUMDB/GONOSUMCHECK 已废弃，按官方推荐用 GOSUMDB 指向的校验库仍走代理
ENV GOSUMDB=sum.golang.org
ENV CGO_ENABLED=1
WORKDIR /home/admin
# make：部分项目用 Makefile 驱动构建；gcc-c++ 留给含 C++ 扩展的依赖；pkg-config/openssl 供 cgo 依赖
RUN set -e && yum install \
    make \
    gcc-c++ \
    pkg-config \
    openssl-devel \
    zip \
    unzip -y; \
    go env GOPROXY CGO_ENABLED

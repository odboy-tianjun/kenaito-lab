FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:system-alinux3
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV RUST_HOME=/usr/local/rust
ENV PATH="${RUST_HOME}/bin:$PATH"
WORKDIR /home/admin
# https://mirrors.ustc.edu.cn/rust-static/dist/rust-1.100.0-x86_64-unknown-linux-gnu.tar.xz
# 由 build.sh 预先下载到本目录，并校验官方 .sha256
ADD rust-1.100.0-x86_64-unknown-linux-gnu.tar.xz /tmp/rust/
# install.sh 把 rustc/cargo 等装进 --prefix；glibc 运行时库 alinux3 自带
# 运行/编译镜像都不需要文档 rust-src rust-mingw 去掉可省下大半体积
RUN set -e && yum install \
    gcc \
    ca-certificates \
    sysstat \
    net-tools -y; \
    cd /tmp/rust/rust-1.100.0-x86_64-unknown-linux-gnu; \
    ./install.sh \
        --prefix=${RUST_HOME} \
        --disable-ldconfig \
        --without=rust-docs,rust-docs-json-preview,rustc-docs,rust-src,rust-mingw,rust-analysis; \
    cd / && rm -rf /tmp/rust; \
    chmod -R a+rx ${RUST_HOME}; \
    rustc -V; \
    cargo -V;

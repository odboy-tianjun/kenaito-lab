FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-rust
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
# cargo 的 home 与缓存目录；运行时镜像不带 CARGO，编译镜像里保留即可
ENV CARGO_HOME=/home/admin/.cargo
ENV PATH="${CARGO_HOME}/bin:$PATH"
WORKDIR /home/admin
# gcc/make：链接 C 库与部分 build.rs；openssl-devel/pkg-config：reqwest 等依赖；
# gcc-c++ 供少部分含 C++ 的依赖；git：从 git 源拉依赖
RUN set -e && yum install \
    gcc \
    gcc-c++ \
    make \
    pkg-config \
    openssl-devel \
    ca-certificates \
    git \
    sysstat \
    net-tools -y;
# crates 源换阿里云镜像（sparse 协议），避免直连 crates.io 超时；与 Python/Node 镜像用同一家源
RUN set -e && mkdir -p ${CARGO_HOME}; \
    printf '%s\n' \
      '[source.crates-io]' \
      'replace-with = "aliyun"' \
      '' \
      '[source.aliyun]' \
      'registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"' \
      > ${CARGO_HOME}/config.toml; \
    cargo -V

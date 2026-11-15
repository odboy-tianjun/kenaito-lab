#!/usr/bin/env bash
# 编译镜像基于 runtime-rust：只需保证 runtime-rust 已构建，这里不再下载 Rust 发行包
set -euo pipefail
cd "$(dirname "$0")"

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-rust
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

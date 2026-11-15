#!/usr/bin/env bash
# 先下载 Go 二进制包到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

VERSION=1.23.12
PKG=go${VERSION}.linux-amd64.tar.gz
URL=https://mirrors.aliyun.com/golang/${PKG}
# 镜像站不可达时的官方源（国内一般较慢）
FALLBACK=https://go.dev/dl/${PKG}

if [ ! -f "${PKG}" ]; then
  curl -fL -o "${PKG}" "${URL}" || curl -fL -o "${PKG}" "${FALLBACK}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-go123
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

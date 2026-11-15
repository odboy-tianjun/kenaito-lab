#!/usr/bin/env bash
# 先下载 Node 二进制包到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

VERSION=18.20.8
PKG=node-v${VERSION}-linux-x64.tar.gz
URL=https://mirrors.aliyun.com/nodejs-release/v${VERSION}/${PKG}
# 镜像站不可达时的官方源
FALLBACK=https://nodejs.org/dist/v${VERSION}/${PKG}

if [ ! -f "${PKG}" ]; then
  curl -fL -o "${PKG}" "${URL}" || curl -fL -o "${PKG}" "${FALLBACK}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-node18
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

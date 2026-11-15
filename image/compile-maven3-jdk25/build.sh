#!/usr/bin/env bash
# 先下载 Maven 到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

DIST=apache-maven-3.9.9-bin.tar.gz
# 每个版本发布后都会留在 archive 上，用它比 dlcdn 稳定（dlcdn 只保留最新版本）
URL=https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/${DIST}

if [ ! -f "${DIST}" ]; then
  curl -fL -o "${DIST}" "${URL}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-maven3-jdk25
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

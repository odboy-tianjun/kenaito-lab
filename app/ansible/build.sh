#!/usr/bin/env bash
# 先下载 Python 源码包到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:ansible
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

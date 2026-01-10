#!/usr/bin/env bash
# 先下载 tengine 源码包到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

TENGINE=tengine-3.1.0.tar.gz
URL=https://tengine.taobao.org/download/tengine-3.1.0.tar.gz

if [ ! -f "${TENGINE}" ]; then
  curl -fL -o "${TENGINE}" "${URL}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:proxy-tengine3
docker build --no-cache -t "${IMAGE}" .
docker push "${IMAGE}"

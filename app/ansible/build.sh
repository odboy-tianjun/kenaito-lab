#!/usr/bin/env bash
# 先下载 Python 源码包到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

PYTHON=Python-3.10.0.tgz
URL=https://www.python.org/ftp/python/3.10.0/${PYTHON}

if [ ! -f "${PYTHON}" ]; then
  curl -fL -o "${PYTHON}" "${URL}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:tools-ansible
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

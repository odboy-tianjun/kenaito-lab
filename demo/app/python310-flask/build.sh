#!/usr/bin/env bash
# 在示例目录下构建示例镜像
set -euo pipefail
cd "$(dirname "$0")"

IMAGE=${IMAGE:-registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-python310-flask}
docker build -t "${IMAGE}" .

if [ "${PUSH:-0}" = "1" ]; then
  docker push "${IMAGE}"
fi

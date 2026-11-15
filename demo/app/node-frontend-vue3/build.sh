#!/usr/bin/env bash
# 在示例目录下构建示例镜像（编译 + 运行两阶段均在本机 docker 内完成）
set -euo pipefail
cd "$(dirname "$0")"

IMAGE=${IMAGE:-registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-node-frontend-vue3}
docker build -t "${IMAGE}" .

if [ "${PUSH:-0}" = "1" ]; then
  docker push "${IMAGE}"
fi

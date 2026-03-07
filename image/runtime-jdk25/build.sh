#!/usr/bin/env bash
# 先运行 prepare-jdk.sh 生成 jdk-25.0.2.tar.gz，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

./prepare-jdk.sh

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-jdk25
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

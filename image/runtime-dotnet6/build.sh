#!/usr/bin/env bash
# 先下载 aspnetcore-runtime 到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

RUNTIME=aspnetcore-runtime-6.0.35-linux-x64.tar.gz
URL=https://download.visualstudio.microsoft.com/download/pr/ccdb3628-8f55-411b-b0f1-669d42604ad8/81283ab8762aaab1be72772711f07f86/${RUNTIME}

if [ ! -f "${RUNTIME}" ]; then
  curl -fL -o "${RUNTIME}" "${URL}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-dotnet6
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

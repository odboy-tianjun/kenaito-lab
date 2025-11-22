#!/usr/bin/env bash
# 先下载 aspnetcore-runtime 到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

RUNTIME=aspnetcore-runtime-8.0.10-linux-x64.tar.gz
URL=https://download.visualstudio.microsoft.com/download/pr/6d143cf6-e215-428e-bcde-9fd50ea0e1be/99652e31b3e0161a3f1f933e0bedf223/${RUNTIME}

if [ ! -f "${RUNTIME}" ]; then
  curl -fL -o "${RUNTIME}" "${URL}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-dotnet8
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

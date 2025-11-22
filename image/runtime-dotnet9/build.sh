#!/usr/bin/env bash
# 先下载 aspnetcore-runtime 到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

RUNTIME=aspnetcore-runtime-9.0.0-rc.2.24474.3-linux-x64.tar.gz
URL=https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.0-rc.2.24474.3/${RUNTIME}

if [ ! -f "${RUNTIME}" ]; then
  curl -fL -o "${RUNTIME}" "${URL}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-dotnet9
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

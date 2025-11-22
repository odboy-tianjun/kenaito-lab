#!/usr/bin/env bash
# 先下载 dotnet-sdk 到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

SDK=dotnet-sdk-9.0.100-rc.2.24474.11-linux-x64.tar.gz
URL=https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.100-rc.2.24474.11/${SDK}

if [ ! -f "${SDK}" ]; then
  curl -fL -o "${SDK}" "${URL}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet9
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

#!/usr/bin/env bash
# 先下载 dotnet-sdk 到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

SDK=dotnet-sdk-6.0.427-linux-x64.tar.gz
URL=https://download.visualstudio.microsoft.com/download/pr/12ee34e8-640c-400e-a6dc-4892b442df92/81d40fc98a5bbbfbafa4cc1ab86d6288/${SDK}

if [ ! -f "${SDK}" ]; then
  curl -fL -o "${SDK}" "${URL}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet6
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

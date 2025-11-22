#!/usr/bin/env bash
# 先下载 dotnet-sdk 到当前目录，再基于本地文件构建镜像
set -euo pipefail
cd "$(dirname "$0")"

SDK=dotnet-sdk-8.0.403-linux-x64.tar.gz
URL=https://download.visualstudio.microsoft.com/download/pr/ca6cd525-677e-4d3a-b66c-11348a6f920a/ec395f498f89d0ca4d67d903892af82d/${SDK}

if [ ! -f "${SDK}" ]; then
  curl -fL -o "${SDK}" "${URL}"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet8
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

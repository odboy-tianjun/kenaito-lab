#!/usr/bin/env bash
# 先下载 Tomcat 10.1.34 到当前目录并校验官方 sha512，再基于本地文件构建镜像
# 官方包直接 ADD 解压，不解包重打：镜像内部与 Tomcat 发行版完全一致，便于对照文档排障
set -euo pipefail
cd "$(dirname "$0")"

VERSION=10.1.34
PKG=apache-tomcat-${VERSION}.tar.gz
URL=https://archive.apache.org/dist/tomcat/tomcat-10/v${VERSION}/bin/${PKG}

if [ ! -f "${PKG}" ]; then
  curl -fL -o "${PKG}" "${URL}"
  curl -fL -o "${PKG}.sha512" "${URL}.sha512"
  # 校验官方 sha512，下载损坏或中间人改写时直接失败（sha512 文件格式：<hash> *<文件名>）
  echo "$(awk '{print $1}' "${PKG}.sha512")  ${PKG}" | shasum -a 512 -c -
  rm -f "${PKG}.sha512"
fi

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-tomcat10
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

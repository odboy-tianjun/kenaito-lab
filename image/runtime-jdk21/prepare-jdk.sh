#!/usr/bin/env bash
# 生成 jdk-21.0.2.tar.gz 供 Dockerfile 中 ADD 使用：
# 下载 OpenJDK 二进制包 → 解包 → 删除体积大的 lib/src.zip → 重新打包 → 清理中间文件
# 产物已存在时直接复用，重复执行不会重新下载
set -euo pipefail
cd "$(dirname "$0")"

VERSION=21.0.2
PKG=jdk-${VERSION}.tar.gz
SRC_PKG=openjdk-${VERSION}_linux-x64_bin.tar.gz
URL=https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/${SRC_PKG}

if [ -f "${PKG}" ]; then
  echo "${PKG} 已存在，跳过"
  exit 0
fi

if [ ! -f "${SRC_PKG}" ]; then
  curl -fL -o "${SRC_PKG}" "${URL}"
fi

tar -xzf "${SRC_PKG}"
rm -f "jdk-${VERSION}/lib/src.zip"
tar -czf "${PKG}" "jdk-${VERSION}"
rm -rf "jdk-${VERSION}" "${SRC_PKG}"

./build.sh

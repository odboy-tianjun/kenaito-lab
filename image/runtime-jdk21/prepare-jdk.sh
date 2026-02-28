#!/usr/bin/env bash
# 生成 jdk-21.0.2.tar.gz 供 Dockerfile 中 ADD 使用：
# 下载 OpenJDK 二进制包 → 解包 → 删除体积大的 lib/src.zip → 重新打包 → 清理解包目录
# 下载的原包 SRC_PKG 保留在本地，重复执行时直接复用、不再重新下载
# 打包时不写入 macOS 扩展属性/ACL：BuildKit 的 ADD 解包带 xattr 的 tar 会报
# lsetxattr ... xattr "com.apple.provenance": no such file or directory
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
# macOS 解包会给文件带上 com.apple.provenance 等扩展属性，需在打包前清除
if command -v xattr >/dev/null 2>&1; then
  xattr -rc "jdk-${VERSION}"
fi
tar --no-xattrs --no-acls -czf "${PKG}" "jdk-${VERSION}"
# 只清理解包出来的目录，保留下载的原包 SRC_PKG 以便复用
rm -rf "jdk-${VERSION}"

./build.sh

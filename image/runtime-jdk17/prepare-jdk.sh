#!/usr/bin/env bash
# 生成 jdk-17.0.2.tar.gz 供 Dockerfile 中 ADD 使用：
# 下载 OpenJDK 二进制包 → 解包 → 删除体积大的 lib/src.zip → 重新打包 → 清理解包目录
# 下载的原包 SRC_PKG 保留在本地，重复执行时直接复用、不再重新下载
# 打包时不写入 macOS 扩展属性/ACL：BSD tar 会把 xattr 编码成 AppleDouble（./._*）条目放进包里，
# BuildKit 的 ADD 解包这种包会报 lsetxattr ... xattr "com.apple.provenance": no such file or directory
# 产物已存在时直接复用，重复执行不会重新下载
set -euo pipefail
cd "$(dirname "$0")"

# https://jdk.java.net/archive/
VERSION=17.0.2
PKG=jdk-${VERSION}.tar.gz
SRC_PKG=openjdk-${VERSION}_linux-x64_bin.tar.gz
URL=https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/${SRC_PKG}

if [ -f "${PKG}" ]; then
  echo "${PKG} 已存在，跳过"
  exit 0
fi

if [ ! -f "${SRC_PKG}" ]; then
  curl -fL -o "${SRC_PKG}" "${URL}"
fi

tar -xzf "${SRC_PKG}"
rm -f "jdk-${VERSION}/lib/src.zip"
# macOS 解包会给文件带上 com.apple.provenance 等扩展属性，BSD tar 会把它们编码成 AppleDouble
# （./._*）条目写进包内，BuildKit 的 ADD 解包时就报 lsetxattr ... no such file or directory
# 注意：xattr -c 对 JDK 内 0444 的 legal/* 文件无权限清不掉，且清掉后也会再次被 macOS 打上，
# 所以不能靠清 xattr，必须让 tar 不写扩展属性：--no-xattrs 不够，还要 COPYFILE_DISABLE=1
COPYFILE_DISABLE=1 tar --no-xattrs --no-acls -czf "${PKG}" "jdk-${VERSION}"
# 只清理解包出来的目录，保留下载的原包 SRC_PKG 以便复用
rm -rf "jdk-${VERSION}"

./build.sh

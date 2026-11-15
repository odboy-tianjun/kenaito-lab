#!/usr/bin/env bash
# 先下载 Rust 官方发行包并校验官方 .sha256，再基于本地文件构建镜像
# compile-rust 复用本目录下载好的包（见 ../compile-rust/build.sh），因此这里也单独保留一份
set -euo pipefail
cd "$(dirname "$0")"

VERSION=1.100.0
TRIPLE=x86_64-unknown-linux-gnu
PKG=rust-${VERSION}-${TRIPLE}.tar.xz
URL=https://mirrors.ustc.edu.cn/rust-static/dist/${PKG}
# 镜像站不可达时的官方源
FALLBACK=https://static.rust-lang.org/dist/${PKG}

if [ ! -f "${PKG}" ]; then
  curl -fL -o "${PKG}" "${URL}" || curl -fL -o "${PKG}" "${FALLBACK}"
fi

# 校验放在下载分支之外：包已存在时也校验；官方 .sha256 内容形如
#   <hash>  rust-<版本>-x86_64-unknown-linux-gnu.tar.xz
# 直接用它校验（文件名与包名一致，不需要改写）；校验通过后不保留 .sha256
if [ ! -f "${PKG}.sha256" ]; then
  curl -fL -o "${PKG}.sha256" "${URL}.sha256" || curl -fL -o "${PKG}.sha256" "${FALLBACK}.sha256"
fi
shasum -a 256 -c "${PKG}.sha256"
rm -f "${PKG}.sha256"

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-rust
docker build -t "${IMAGE}" .
docker push "${IMAGE}"

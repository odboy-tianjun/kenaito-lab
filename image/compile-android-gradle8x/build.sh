#!/usr/bin/env bash
# 预下载镜像构建所需的全部压缩包（Android 组件包 + cmdline-tools + Gradle），逐个校验后构建镜像。
# 为什么不用 sdkmanager 在线安装：它在 Docker 里从镜像站下载后解压会报
# “Error on ZipFile unknown archive”（包本身完好、sha1 与仓库清单一致），拿到的其实是残包；
# 这里用 curl 下载并校验 sha1，再由 Dockerfile 解压到 SDK 目录。
set -euo pipefail
cd "$(dirname "$0")"

# 阿里云镜像站没有 Android SDK 仓库，SDK 相关包用腾讯云同步的 AndroidSDK 镜像
SDK_BASE=https://mirrors.cloud.tencent.com/AndroidSDK

# Android cmdline-tools（sdkmanager / avdmanager 等工具）
CMDLINE_ZIP=commandlinetools-linux-13114758_latest.zip
CMDLINE_URL=${SDK_BASE}/${CMDLINE_ZIP}

# Gradle：8.14.x 与 AGP 8.x 兼容。阿里云没有独立的 gradle 分区，
# 用其在 macports distfiles 下同步的官方发行包（sha256 与 services.gradle.org 一致）
GRADLE_VERSION=8.14.3
GRADLE_ZIP=gradle-${GRADLE_VERSION}-bin.zip
GRADLE_URL=https://mirrors.aliyun.com/macports/distfiles/gradle/${GRADLE_ZIP}
# 阿里云镜像不提供 .sha256 文件，校验值取自官方（几十字节，联网获取一次即可）
GRADLE_SHA_URL=https://services.gradle.org/distributions/${GRADLE_ZIP}.sha256

# SDK 组件包：包名 | sha1。sha1 取自仓库清单 repository2-3.xml，与官方一致
SDK_PACKAGES=$(cat <<'EOF'
platform-tools_r37.0.3-linux.zip e1579b288a7ae4e9bc28dedec6a154d78b3c04ed
platform-35_r02.zip 0bb560a90a7a2cbd0dd8348224d518b638fe7949
platform-36_r02.zip 2c1a80dd4d9f7d0e6dd336ec603d9b5c55a6f576
build-tools_r35_linux.zip 2cfaa0bbb2336e9ec18ed3ecea84fa2e2af607bc
android-ndk-r27-linux.zip 5e5cd517bdb98d7e0faf2c494a3041291e71bdcc
cmake-3.22.1-linux.zip fd0a48b4a758310df8c7aa51f59840ed48fe7ed8
EOF
)

# 下载到临时文件，完整下载后才改名：中途 Ctrl+C 不会留下“看起来已下载”的残包；
# --speed-limit/--speed-time：速率低于 50KB/s 持续 30 秒就断开重试，避免镜像偶发降速时一直挂着
download() {
  local url="$1" out="$2"
  if [ ! -s "${out}" ]; then
    curl -fL --retry 5 --retry-delay 2 --speed-limit 51200 --speed-time 30 -o "${out}.part" "${url}"
    mv "${out}.part" "${out}"
  fi
}

# cmdline-tools：官方未公开独立校验文件，只校验 zip 完整可解
download "${CMDLINE_URL}" "${CMDLINE_ZIP}"
unzip -tq "${CMDLINE_ZIP}" > /dev/null
echo "${CMDLINE_ZIP}: OK"

# Gradle：官方 .sha256 内容只有 64 位十六进制哈希、没有文件名，不能直接 shasum -c，自己算完比对
download "${GRADLE_URL}" "${GRADLE_ZIP}"
if [ ! -s "${GRADLE_ZIP}.sha256" ]; then
  curl -fL --retry 3 --retry-delay 2 -o "${GRADLE_ZIP}.sha256.part" "${GRADLE_SHA_URL}"
  mv "${GRADLE_ZIP}.sha256.part" "${GRADLE_ZIP}.sha256"
fi
EXPECTED=$(tr -d ' \t\r\n' < "${GRADLE_ZIP}.sha256")
ACTUAL=$(shasum -a 256 "${GRADLE_ZIP}" | awk '{print $1}')
if [ "${EXPECTED}" != "${ACTUAL}" ]; then
  echo "sha256 校验失败：期望 ${EXPECTED}，实际 ${ACTUAL}；删除 ${GRADLE_ZIP} 后重试" >&2
  exit 1
fi
echo "${GRADLE_ZIP}: OK"
rm -f "${GRADLE_ZIP}.sha256"

# SDK 组件包：逐个下载并校验 sha1，不一致则删除残包退出
while read -r pkg sha1; do
  [ -z "${pkg}" ] && continue
  download "${SDK_BASE}/${pkg}" "${pkg}"
  ACTUAL=$(shasum -a 1 "${pkg}" | awk '{print $1}')
  if [ "${sha1}" != "${ACTUAL}" ]; then
    echo "sha1 校验失败：${pkg} 期望 ${sha1}，实际 ${ACTUAL}；已删除，重跑即可" >&2
    rm -f "${pkg}"
    exit 1
  fi
  echo "${pkg}: OK"
done <<< "${SDK_PACKAGES}"

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-android-gradle8x
# --progress=plain：NDK 等包体积大，plain 日志便于看进度与排查
docker build --progress=plain -t "${IMAGE}" .
docker push "${IMAGE}"

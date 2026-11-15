#!/usr/bin/env bash
# 构建 apk 并把产物拷到宿主机 dist/（Android 无运行阶段，只交付 apk）
set -euo pipefail
cd "$(dirname "$0")"

IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-android-kotlin
# docker cp 的路径相对容器根目录解析（不是相对 WORKDIR），所以这里必须写绝对路径
APK=/workspace/app/build/outputs/apk/debug/app-debug.apk

# docker build 不支持 -v 挂载宿主目录（那是 docker run 的选项）；依赖包复用靠 BuildKit 的层缓存，
# Dockerfile 里先 COPY gradle 构建脚本再 COPY 源码，依赖声明不变时这一层直接命中缓存
docker build --progress=plain -t "${IMAGE}" .

# 从镜像里把 apk 取出来：先 create 出容器（不启动），docker cp 后删除
mkdir -p dist
CID=$(docker create "${IMAGE}")
docker cp "${CID}:${APK}" dist/app-debug.apk
docker rm -f "${CID}" > /dev/null
ls -lh dist/app-debug.apk

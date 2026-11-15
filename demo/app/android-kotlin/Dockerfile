# Android 没有运行阶段：产物是 apk，由真机 / 模拟器安装，
# 所以这里不是前后两个 FROM，而是「编译镜像 + 取出产物」两步（见 build.sh）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-android-gradle8x
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
WORKDIR /workspace
# 先拷构建脚本再拷源码：依赖声明不变时，这一层可直接命中构建缓存，不必重跑依赖解析
COPY settings.gradle.kts build.gradle.kts gradle.properties ./
COPY app/build.gradle.kts app/proguard-rules.pro ./app/
COPY app/src ./app/src
# 直接使用镜像内置的 Gradle 8.14.3（不带 wrapper：wrapper 会再联网下载一份 gradle 发行包）
#   assembleDebug    产出 app/build/outputs/apk/debug/app-debug.apk
#   assembleRelease  产出 app-release-unsigned.apk（需自行签名后安装）
RUN set -e && gradle :app:assembleDebug --no-daemon --console=plain; \
    ls -lh app/build/outputs/apk/debug/

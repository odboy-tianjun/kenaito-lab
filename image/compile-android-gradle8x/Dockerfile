# Android 只有编译镜像，没有 runtime：构建产物是 apk / aar / jar，由真机或模拟器安装运行，
# 不存在“在容器里跑起来”的服务进程；apk 用镜像内置的 JDK 21 + SDK 35 + Gradle 8.x 产出即可
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-jdk21
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
# SDK 装到 /usr/local 下而不是 $HOME：容器里 HOME 可能随 docker run -u 变化，
# sdkmanager 发现 HOME 下没有 SDK 会尝试重新下载，路径固定后不受影响
ENV ANDROID_SDK_ROOT=/usr/local/android-sdk
ENV ANDROID_HOME=/usr/local/android-sdk
ENV GRADLE_HOME=/usr/local/gradle8
# Gradle 缓存与守护进程目录固定到 admin 家目录，宿主 -v ~/.gradle:/home/admin/.gradle 可直接复用依赖缓存
ENV GRADLE_USER_HOME=/home/admin/.gradle
ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${GRADLE_HOME}/bin:$PATH"
WORKDIR /home/admin
# 由 build.sh 预先下载并校验 sha1/sha256 到本目录（构建上下文里不能忽略这些 zip），
# 全部用 COPY：ADD 对本地 tar 会自动解压，这里要的是原样放进镜像再按需解压
COPY commandlinetools-linux-13114758_latest.zip /tmp/android-cmdline-tools/
# cmdline-tools 的 zip 解出来是 cmdline-tools/ 目录，sdkmanager 要求它放在 cmdline-tools/latest 下（见下方 RUN）
COPY gradle-8.14.3-bin.zip /usr/local/
COPY platform-tools_r37.0.3-linux.zip platform-35_r02.zip platform-36_r02.zip \
     build-tools_r35_linux.zip android-ndk-r27-linux.zip cmake-3.22.1-linux.zip \
     /tmp/sdk-packages/
# unzip：解 cmdline-tools / Gradle 包；git 供部分 AGP 插件拉依赖（libstdc++ 是 system-alinux3 自带的基础库）
RUN set -e && yum install \
    unzip \
    zip \
    git \
    ca-certificates \
    which \
    sysstat \
    net-tools -y; \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools; \
    unzip -q /usr/local/gradle-8.14.3-bin.zip -d /usr/local; \
    mv /usr/local/gradle-8.14.3 ${GRADLE_HOME}; \
    unzip -q /tmp/android-cmdline-tools/commandlinetools-linux-13114758_latest.zip -d ${ANDROID_SDK_ROOT}; \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools-latest; \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools; \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools-latest ${ANDROID_SDK_ROOT}/cmdline-tools/latest; \
    rm -rf /tmp/android-cmdline-tools; \
    gradle -v; \
    sdkmanager --version
# 装编译所需组件（版本与 README 中的说明保持一致）：
#   platform-tools      adb / fastboot，apk 校验与真机安装用
#   platforms;android-35  compileSdk 35
#   platforms;android-36  预留 Android 16，targetSdk 36 的项目可直接编
#   build-tools;35.0.0  aapt2 / d8 / zipalign / apksigner
#   ndk;27.0.12077973   原生代码（CMake / ndk-build）
#   cmake;3.22.1        由 SDK 提供 linux-x86_64 预编译二进制，与仓库其余镜像同为 x86_64；
#                       ninja 随该包一起装到 cmake/3.22.1/bin 下，无需单独下载
# 组件不从 sdkmanager 在线安装：它在 Docker 里从镜像站下载后解压会报
# “Error on ZipFile unknown archive”（包本身完好、sha1 与仓库清单一致，拿到的是残包）。
# 改为 build.sh 预下载 + 校验 sha1，这里按各包的目录结构解压：
#   platform-tools_r37.0.3-linux.zip  -> platform-tools/
#   platform-35_r02.zip               -> android-35/     （移到 platforms/android-35）
#   platform-36_r02.zip               -> android-36/     （移到 platforms/android-36）
#   build-tools_r35_linux.zip         -> android-15/     （移到 build-tools/35.0.0，包内目录名与版本不一致）
#   android-ndk-r27-linux.zip         -> android-ndk-r27/（移到 ndk/27.0.12077973）
# cmake-3.22.1-linux.zip            -> 无顶层目录     （直接解到 cmake/3.22.1）
RUN set -e && mkdir -p "${ANDROID_SDK_ROOT}/platforms" \
                       "${ANDROID_SDK_ROOT}/build-tools" \
                       "${ANDROID_SDK_ROOT}/ndk" \
                       "${ANDROID_SDK_ROOT}/cmake/3.22.1"; \
    unzip -q /tmp/sdk-packages/platform-tools_r37.0.3-linux.zip -d "${ANDROID_SDK_ROOT}"; \
    unzip -q /tmp/sdk-packages/platform-35_r02.zip -d /tmp/sdk-packages/p35; \
    mv /tmp/sdk-packages/p35/android-35 "${ANDROID_SDK_ROOT}/platforms/android-35"; \
    unzip -q /tmp/sdk-packages/platform-36_r02.zip -d /tmp/sdk-packages/p36; \
    mv /tmp/sdk-packages/p36/android-36 "${ANDROID_SDK_ROOT}/platforms/android-36"; \
    unzip -q /tmp/sdk-packages/build-tools_r35_linux.zip -d /tmp/sdk-packages/bt; \
    mv /tmp/sdk-packages/bt/android-15 "${ANDROID_SDK_ROOT}/build-tools/35.0.0"; \
    unzip -q /tmp/sdk-packages/android-ndk-r27-linux.zip -d /tmp/sdk-packages/ndk; \
    mv /tmp/sdk-packages/ndk/android-ndk-r27 "${ANDROID_SDK_ROOT}/ndk/27.0.12077973"; \
    unzip -q /tmp/sdk-packages/cmake-3.22.1-linux.zip -d "${ANDROID_SDK_ROOT}/cmake/3.22.1"; \
    rm -rf /tmp/sdk-packages/p35 /tmp/sdk-packages/p36 /tmp/sdk-packages/bt /tmp/sdk-packages/ndk; \
    chmod +x "${ANDROID_SDK_ROOT}/platform-tools/adb" \
             "${ANDROID_SDK_ROOT}/build-tools/35.0.0/aapt2" \
             "${ANDROID_SDK_ROOT}/cmake/3.22.1/bin/cmake"; \
    sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" --list_installed || true; \
    for f in \
      "${ANDROID_SDK_ROOT}/platform-tools/adb" \
      "${ANDROID_SDK_ROOT}/platforms/android-35/android.jar" \
      "${ANDROID_SDK_ROOT}/platforms/android-36/android.jar" \
      "${ANDROID_SDK_ROOT}/build-tools/35.0.0/aapt2" \
      "${ANDROID_SDK_ROOT}/ndk/27.0.12077973/ndk-build" \
      "${ANDROID_SDK_ROOT}/cmake/3.22.1/bin/cmake"; do \
      if [ ! -x "$f" ] && [ ! -f "$f" ]; then \
        echo "组件文件缺失：$f" >&2; \
        ls -la "${ANDROID_SDK_ROOT}" >&2; \
        exit 1; \
      fi; \
    done; \
    "${ANDROID_SDK_ROOT}/build-tools/35.0.0/aapt2" version
# Gradle 全局配置：只改仓库地址（阿里云代理 Google / Maven Central / Gradle 插件仓库），
# 其余保持 Gradle 默认行为；项目里的 Gradle Wrapper / 自身依赖仍按各自配置解析
COPY gradle-init.gradle ${GRADLE_USER_HOME}/init.d/init.gradle
# Android SDK 与 NDK 目录只读执行权限，非 root 用户（docker run -u）也能用
RUN set -e && chmod -R a+rx ${ANDROID_SDK_ROOT} ${GRADLE_HOME}; \
    mkdir -p ${GRADLE_USER_HOME}; \
    gradle --version

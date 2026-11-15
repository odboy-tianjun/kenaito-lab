# android-java 示例

演示如何用 `compile-android-gradle8x` 编译一个纯 Java Android 应用，并把 `debug` apk 取回宿主机。
与 [`android-kotlin`](../android-kotlin/README.md) 示例内容相同，区别是：不引入 Kotlin 插件与 Kotlin 标准库，
构建更快，适合只需要 Java 的项目。

Android **没有运行阶段**：产物是 apk，由真机或模拟器安装运行，所以本示例不是 `compile → runtime` 两阶段，
而是「编译镜像 + 把产物拷出来」两个动作。

| 阶段 | 镜像 | 说明 |
| --- | --- | --- |
| 编译 | `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-android-gradle8x` | JDK 21 + Android SDK 35/36 + build-tools 35.0.0 + NDK 27 + Gradle 8.14.3 |
| 运行 | — | apk 由真机 / 模拟器安装，容器里不驻留进程 |

### 示例内容

```
android-java/
├── settings.gradle.kts            # 阿里云仓库地址，不提交 gradle wrapper
├── build.gradle.kts               # 只有 AGP 8.13.2
├── gradle.properties              # android.useAndroidX=true 等
├── app/
│   ├── build.gradle.kts           # compileSdk 35、minSdk 24、targetSdk 35
│   ├── proguard-rules.pro
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/cn/odboy/demo/java/MainActivity.java
│       └── res/                   # layout / strings / styles
├── Dockerfile                     # 基于 compile-android-gradle8x 执行 assembleDebug
├── build.sh                       # 构建镜像并把 apk 拷到 dist/
└── .gitignore / .dockerignore
```

### 构建并取出 apk

```shell
sh build.sh
# 产物：dist/app-debug.apk
```

`build.sh` 做的是两件事：

```shell
# 1. 构建（docker build 不支持 -v 挂载宿主目录，依赖复用靠层缓存）
docker build --progress=plain \
  -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-android-java .

# 2. 取出产物（Android 没有“运行”这一步，只能从镜像里拷）
docker create --name android-java-out registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-android-java
docker cp android-java-out:/workspace/app/build/outputs/apk/debug/app-debug.apk dist/app-debug.apk
docker rm -f android-java-out
```

### 日常开发：直接挂载源码构建

改代码后不用重新 `docker build`，挂载当前目录跑 Gradle 即可，产物出现在宿主机的 `app/build/` 下：

```shell
docker run --rm \
  -v "$PWD":/workspace \
  -v ~/.gradle:/home/admin/.gradle \
  -w /workspace \
  registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-android-gradle8x \
  gradle :app:assembleDebug --no-daemon --console=plain

ls -lh app/build/outputs/apk/debug/app-debug.apk
```

清工程：

```shell
docker run --rm -v "$PWD":/workspace -w /workspace \
  registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-android-gradle8x \
  gradle clean --no-daemon
```

### 校验与安装 apk

debug 包用 SDK 自带的调试签名，可直接安装。

```shell
# 校验签名与基本信息
docker run --rm -v "$PWD/dist":/dist \
  registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-android-gradle8x \
  sh -c 'apksigner verify -v /dist/app-debug.apk && aapt dump badging /dist/app-debug.apk'

# 连上真机（USB 调试）后安装
adb install -r dist/app-debug.apk
adb shell am start -n cn.odboy.demo.java/.MainActivity
```

模拟器安装：把 `dist/app-debug.apk` 拖进模拟器窗口，或 `adb install -r`。

### 关键点

**纯 Java**：`build.gradle.kts` 里只有 `com.android.application`，没有 Kotlin 插件，镜像里也不需要额外装 Kotlin 编译器。

**不用 gradle wrapper**：镜像已内置 Gradle 8.14.3，`gradle :app:assembleDebug` 直接可用；
wrapper 会再联网下载一份 gradle 发行包（约 130MB），在离线 / 内网环境里还会卡住。

**国内源**：`settings.gradle.kts` 里直接用阿里云仓库地址（`maven.aliyun.com/repository/google`、`/public`、
`/gradle-plugin`），AGP 与 AndroidX 依赖都从阿里云拉取；镜像里另有 `~/.gradle/init.d/init.gradle`
把项目里残留的 `dl.google.com` / Maven Central / Gradle Plugin Portal 地址再改写一遍，保证不会直连国外源。

**SDK 路径**：来自镜像环境变量 `ANDROID_SDK_ROOT=/usr/local/android-sdk`，不需要 `local.properties`；
在本机 Android Studio 里打开时再补 `sdk.dir`。

**release 包**：`gradle :app:assembleRelease` 产出的是未签名 apk，需要自己的 keystore 签名后才能安装。

**JDK**：AGP 8.13 要求 JDK 17+，镜像用 JDK 21，`compileOptions` 里指定 Java 17 字节码。

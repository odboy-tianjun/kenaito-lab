plugins {
    id("com.android.application")
}

android {
    namespace = "cn.odboy.demo.java"
    compileSdk = 35

    defaultConfig {
        applicationId = "cn.odboy.demo.java"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        // debug 用 SDK 内置的调试签名即可安装，示例不需要 release keystore
        debug {
            isMinifyEnabled = false
        }
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    // BuildConfig 需要在 AGP 8.x 里显式打开
    buildFeatures {
        buildConfig = true
    }

    // JDK 21 编译，字节码与 Android 兼容
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.0")
}

// appcompat 1.7.0 传递依赖 kotlin-stdlib-jdk7/jdk8:1.6.21，而 AGP 8.x 工具链带 kotlin-stdlib:1.8.22。
// Kotlin 1.8 起 jdk7/jdk8 的类已合并进主 stdlib，两个版本同时出现会报 Duplicate class；
// 用 force 把三个坐标强制统一到同一版本（纯 Java 工程没有 Kotlin 插件，1.8.22 即工具链版本）。
configurations.configureEach {
    resolutionStrategy {
        force(
            "org.jetbrains.kotlin:kotlin-stdlib:1.8.22",
            "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.22",
            "org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.22",
        )
    }
}

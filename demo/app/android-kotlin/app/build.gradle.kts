plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "cn.odboy.demo.kotlin"
    compileSdk = 35

    defaultConfig {
        applicationId = "cn.odboy.demo.kotlin"
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

    // AppCompat 主题与 BuildConfig 需要在 AGP 8.x 里显式打开
    buildFeatures {
        buildConfig = true
    }

    // JDK 21 编译，字节码与 Android 兼容
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.0")
}

// appcompat 1.7.0 传递依赖 kotlin-stdlib-jdk7/jdk8:1.6.21，与 Kotlin 插件带入的 stdlib 版本不一致。
// Kotlin 1.8 起 jdk7/jdk8 的类已合并进主 stdlib，版本错开会报 Duplicate class；
// 用 force 统一到 Kotlin 2.2.21 对应的 stdlib 版本。
configurations.configureEach {
    resolutionStrategy {
        force(
            "org.jetbrains.kotlin:kotlin-stdlib:2.2.21",
            "org.jetbrains.kotlin:kotlin-stdlib-jdk7:2.2.21",
            "org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.2.21",
        )
    }
}

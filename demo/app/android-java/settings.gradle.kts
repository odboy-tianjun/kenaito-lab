pluginManagement {
    repositories {
        // 阿里云代理 Google / Maven Central / Gradle Plugin Portal（镜像内 init.d/init.gradle 也做同样的改写，
        // 这里直接写阿里云地址，脱离镜像在本地构建时也走国内源）
        maven("https://maven.aliyun.com/repository/google")
        maven("https://maven.aliyun.com/repository/public")
        maven("https://maven.aliyun.com/repository/gradle-plugin")
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven("https://maven.aliyun.com/repository/google")
        maven("https://maven.aliyun.com/repository/public")
    }
}

rootProject.name = "android-java"
include(":app")

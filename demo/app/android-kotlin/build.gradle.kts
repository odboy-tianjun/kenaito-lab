// 根工程只声明插件版本，各模块按需 apply
// AGP 8.13.x 需要 Gradle 8.13+、JDK 17+（镜像为 JDK 21 + Gradle 8.14.3）
plugins {
    id("com.android.application") version "8.13.2" apply false
    id("org.jetbrains.kotlin.android") version "2.2.21" apply false
}

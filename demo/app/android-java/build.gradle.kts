// 纯 Java 工程：只声明 AGP，不需要 Kotlin 插件
// AGP 8.13.x 需要 Gradle 8.13+、JDK 17+（镜像为 JDK 21 + Gradle 8.14.3）
plugins {
    id("com.android.application") version "8.13.2" apply false
}

package cn.odboy.demo.kotlin

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // 启动即显示构建信息，便于在真机上确认装的是哪一次构建的包
        val info = buildString {
            appendLine(getString(R.string.hello))
            appendLine("versionName: ${BuildConfig.VERSION_NAME}")
            appendLine("applicationId: ${BuildConfig.APPLICATION_ID}")
            append("BuildConfig.DEBUG: ${BuildConfig.DEBUG}")
        }
        findViewById<TextView>(R.id.message).text = info
    }
}

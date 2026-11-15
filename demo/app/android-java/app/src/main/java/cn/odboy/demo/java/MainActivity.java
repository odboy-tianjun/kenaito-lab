package cn.odboy.demo.java;

import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // 启动即显示构建信息，便于在真机上确认装的是哪一次构建的包
        StringBuilder info = new StringBuilder();
        info.append(getString(R.string.hello)).append('\n');
        info.append("versionName: ").append(BuildConfig.VERSION_NAME).append('\n');
        info.append("applicationId: ").append(BuildConfig.APPLICATION_ID).append('\n');
        info.append("BuildConfig.DEBUG: ").append(BuildConfig.DEBUG);

        TextView message = findViewById(R.id.message);
        message.setText(info.toString());
    }
}

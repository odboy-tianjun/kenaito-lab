package cn.odboy.demo;

import org.springframework.boot.SpringBootVersion;
import org.springframework.stereotype.Component;

/**
 * Boot 环境下的版本信息实现。
 */
@Component
public class BootRuntimeInfo implements DemoController.RuntimeInfo {

    @Override
    public String appVersion() {
        return "Spring Boot " + SpringBootVersion.getVersion();
    }

    @Override
    public String hostname() {
        return RuntimeInfo.hostnameOrUnknown();
    }
}

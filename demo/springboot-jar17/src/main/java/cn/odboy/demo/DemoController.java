package cn.odboy.demo;

import java.lang.management.ManagementFactory;
import java.net.InetAddress;
import java.time.Duration;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.SpringVersion;
import org.springframework.boot.SpringBootVersion;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

/**
 * 运行时信息接口，用于确认镜像里的 JDK / 时区 / 端口等是否符合预期。
 */
@RestController
public class DemoController {

    private static final ZoneId TZ8 = ZoneId.of("Asia/Shanghai");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss XXX");

    @Value("${app.name:spring demo}")
    private String appName;

    @Value("${server.port:0}")
    private int port;

    /** 返回 JDK、Spring 版本、主机名、时区与运行时长，浏览器可直接看 JSON */
    @GetMapping({"/", "/api/info"})
    public Map<String, Object> info() {
        Runtime runtime = Runtime.getRuntime();
        long uptimeMillis = ManagementFactory.getRuntimeMXBean().getUptime();

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("message", appName + " is running");
        body.put("java", System.getProperty("java.version"));
        body.put("javaHome", System.getProperty("java.home"));
        body.put("vm", System.getProperty("java.vm.name") + " " + System.getProperty("java.vm.version"));
        body.put("spring", SpringVersion.getVersion());
        body.put("application", "Spring Boot " + SpringBootVersion.getVersion());
        body.put("os", System.getProperty("os.name") + " " + System.getProperty("os.arch"));
        body.put("hostname", hostname());
        body.put("port", port);
        body.put("zoneId", ZoneId.systemDefault().getId());
        body.put("time", ZonedDateTime.now(TZ8).format(TIME_FMT));
        body.put("uptime", Duration.ofMillis(uptimeMillis).toString());
        body.put("memory", runtime.totalMemory() / 1024 / 1024 + "MB / max " + runtime.maxMemory() / 1024 / 1024 + "MB");
        return body;
    }

    /** 带路径参数的示例接口 */
    @GetMapping("/api/hello/{name}")
    public Map<String, Object> hello(@PathVariable String name) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("message", "Hello, " + name + "!");
        body.put("time", ZonedDateTime.now(TZ8).format(TIME_FMT));
        return body;
    }

    private static String hostname() {
        try {
            return InetAddress.getLocalHost().getHostName();
        } catch (Exception e) {
            return "unknown";
        }
    }
}

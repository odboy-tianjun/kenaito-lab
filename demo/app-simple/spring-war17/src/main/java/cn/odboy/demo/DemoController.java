package cn.odboy.demo;

import java.lang.management.ManagementFactory;
import java.net.InetAddress;
import java.time.Duration;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

import jakarta.servlet.ServletContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.SpringVersion;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

/**
 * 运行时信息接口。与 demo/app-simple/springboot-jar17 里的同名类保持一致的输出结构，方便对比 jar 与 war 两种打包方式。
 */
@RestController
public class DemoController {

    private static final ZoneId TZ8 = ZoneId.of("Asia/Shanghai");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss XXX");

    @Autowired(required = false)
    private ServletContext servletContext;

    @GetMapping({"/", "/info"})
    public Map<String, Object> info() {
        Runtime runtime = Runtime.getRuntime();
        long uptimeMillis = ManagementFactory.getRuntimeMXBean().getUptime();

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("message", "spring-war17 is running");
        body.put("java", System.getProperty("java.version"));
        body.put("javaHome", System.getProperty("java.home"));
        body.put("vm", System.getProperty("java.vm.name") + " " + System.getProperty("java.vm.version"));
        body.put("spring", SpringVersion.getVersion());
        body.put("application", "Spring MVC " + SpringVersion.getVersion() + " + " + servletContextName());
        body.put("os", System.getProperty("os.name") + " " + System.getProperty("os.arch"));
        body.put("hostname", hostname());
        body.put("contextPath", servletContext == null ? "" : servletContext.getContextPath());
        body.put("zoneId", ZoneId.systemDefault().getId());
        body.put("time", ZonedDateTime.now(TZ8).format(TIME_FMT));
        body.put("uptime", Duration.ofMillis(uptimeMillis).toString());
        body.put("memory", runtime.totalMemory() / 1024 / 1024 + "MB / max " + runtime.maxMemory() / 1024 / 1024 + "MB");
        return body;
    }

    @GetMapping("/hello/{name}")
    public Map<String, Object> hello(@PathVariable String name) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("message", "Hello, " + name + "!");
        body.put("time", ZonedDateTime.now(TZ8).format(TIME_FMT));
        return body;
    }

    private String servletContextName() {
        if (servletContext == null) {
            return "Tomcat";
        }
        return servletContext.getServerInfo();
    }

    private static String hostname() {
        try {
            return InetAddress.getLocalHost().getHostName();
        } catch (Exception e) {
            return "unknown";
        }
    }
}

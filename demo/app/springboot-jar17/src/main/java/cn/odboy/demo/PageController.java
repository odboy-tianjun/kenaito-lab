package cn.odboy.demo;

import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 页面路由，模板见 src/main/resources/templates/index.html。
 */
@Controller
public class PageController {

    private final DemoController demoController;

    public PageController(DemoController demoController) {
        this.demoController = demoController;
    }

    /** 渲染 templates/index.html；只有 /page 返回页面，接口仍返回 JSON */
    @GetMapping("/page")
    public String page(Model model) {
        Map<String, Object> info = demoController.info();
        model.addAttribute("info", info);
        return "index";
    }
}

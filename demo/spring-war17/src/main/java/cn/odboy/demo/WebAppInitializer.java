package cn.odboy.demo;

import org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer;

/**
 * 替代 web.xml：Tomcat 10.1 启动时通过 Servlet 3+ 的 ServiceLoader 发现本类，
 * 由它注册 DispatcherServlet 与根容器。前缀 /api 的请求进 Spring MVC，其余请求交给 Tomcat 默认 Servlet。
 */
public class WebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    @Override
    protected Class<?>[] getRootConfigClasses() {
        return null;
    }

    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class<?>[]{WebConfig.class};
    }

    @Override
    protected String[] getServletMappings() {
        return new String[]{"/api/*"};
    }
}

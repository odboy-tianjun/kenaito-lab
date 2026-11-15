package cn.odboy.demo;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.json.Jackson2ObjectMapperBuilder;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ViewResolverRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.thymeleaf.spring6.SpringTemplateEngine;
import org.thymeleaf.spring6.view.ThymeleafViewResolver;
import org.thymeleaf.templateresolver.ClassLoaderTemplateResolver;

import java.util.List;

/**
 * Spring MVC 配置。@EnableWebMvc 负责 JSON 等默认消息转换器，这里额外加上 Thymeleaf 视图解析。
 */
@Configuration
@EnableWebMvc
@ComponentScan("cn.odboy.demo")
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void configureViewResolvers(ViewResolverRegistry registry) {
        ClassLoaderTemplateResolver resolver = new ClassLoaderTemplateResolver();
        // 与 springboot-jar17 保持同一套模板路径：src/main/resources/templates/*.html
        resolver.setPrefix("templates/");
        resolver.setSuffix(".html");
        resolver.setTemplateMode("HTML");
        resolver.setCharacterEncoding("UTF-8");
        resolver.setCacheable(true);

        SpringTemplateEngine engine = new SpringTemplateEngine();
        engine.setTemplateResolver(resolver);

        ThymeleafViewResolver viewResolver = new ThymeleafViewResolver();
        viewResolver.setTemplateEngine(engine);
        viewResolver.setCharacterEncoding("UTF-8");
        viewResolver.setOrder(1);
        registry.viewResolver(viewResolver);
    }

    @Override
    public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
        // 显式给出 Jackson 转换器，方便后续统一改日期格式等；默认配置已足够
        converters.add(new MappingJackson2HttpMessageConverter(Jackson2ObjectMapperBuilder.json().build()));
    }
}

package com.app.demo.Config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Serve files under /uploads/** from the file system directory
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:C:/Users/hibar/Downloads/demo/demo/uploads/");
    }
}

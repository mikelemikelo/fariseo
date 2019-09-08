package com.mikele.fariseo.application;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;


/**
 * Main application class for spring boot
 */
@Configuration
@ComponentScan(basePackages = {"com.mikele.fariseo"})
@SpringBootApplication
public class Application {

    private static final Logger LOGGER = LoggerFactory.getLogger(Application.class);

    public static void main(final String[] args) {
        LOGGER.info("Spring Boot up and running");
        SpringApplication.run(Application.class, args);
    }


}

package com.maabrle.web;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class WebApplication {

	public static final Logger LOGGER = LoggerFactory.getLogger(WebApplication.class);

	public static void main(String[] args) {
		LOGGER.debug("Starting '{}'", WebApplication.class.getName());
		
		SpringApplication.run(WebApplication.class, args);
		
		LOGGER.debug("Finishing '{}'", WebApplication.class.getName());
	}

}

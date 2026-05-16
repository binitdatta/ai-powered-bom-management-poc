package com.bomiq.sdm;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories(basePackages = "com.bomiq.sdm.repository")
public class BomIqSdmApplication {

    public static void main(String[] args) {
        SpringApplication.run(BomIqSdmApplication.class, args);
    }
}

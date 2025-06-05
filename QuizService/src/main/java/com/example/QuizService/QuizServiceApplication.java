package com.example.QuizService;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

@SpringBootApplication
@EnableDiscoveryClient
@EnableMongoRepositories
public class QuizServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(QuizServiceApplication.class, args);
    }
}

package com.example.barcodeserver;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.example.barcodeserver.mapper")
public class BarcodeServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(BarcodeServerApplication.class, args);
    }

}
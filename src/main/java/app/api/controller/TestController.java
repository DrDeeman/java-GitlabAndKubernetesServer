package app.api.controller;

import org.springframework.web.bind.annotation.RestController;

import app.api.dto.Body;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;


@RestController
@RequiredArgsConstructor
@Slf4j
public class TestController {
    
    @PostMapping("isTest")
    public ResponseEntity<Void> postMethodName(@RequestBody Body body) {
        log.info("message:{}", body);
        
        return ResponseEntity.ok().build();
    }
    
}

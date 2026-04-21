package app.api.controller;

import org.springframework.web.bind.annotation.RestController;

import app.api.dto.Body;
import app.dao.ProductsDAO;
import app.db.entity.Products;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.util.List;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;


@RestController
@RequiredArgsConstructor
@Slf4j
public class TestController {
    
    private final ProductsDAO productsDAO;

    @PostMapping("isTest")
    public List<Products> postMethodName(@RequestBody Body body) {
        log.info("message:{}", body);
        
        return productsDAO.getProducts();
    }
    
}
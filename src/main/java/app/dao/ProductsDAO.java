package app.dao;

import java.util.List;

import org.springframework.stereotype.Service;

import app.db.entity.Products;
import app.db.repository.ProductRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProductsDAO {
    

    private final ProductRepository productsRepository;

    public List<Products> getProducts(){
        return productsRepository.findAll();
    }
}

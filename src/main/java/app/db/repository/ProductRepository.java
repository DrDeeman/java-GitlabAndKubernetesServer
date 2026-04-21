package app.db.repository;

import java.math.BigDecimal;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import app.db.entity.Products;

@Repository
public interface ProductRepository extends JpaRepository<Products, BigDecimal>{

    
}

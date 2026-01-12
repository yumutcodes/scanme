package com.backend.repository;

import com.backend.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, String> {
    Optional<Product> findByBarcode(String barcode);
    Optional<Product> findByProductName(String productName);

    @Query("select p from Product p left join fetch p.ingredients where p.barcode = :barcode")
    Optional<Product> findWithIngredientsByBarcode(@Param("barcode") String barcode);
}

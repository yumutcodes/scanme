package com.backend.repository;

import com.backend.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, String> {
    Optional<Product> findByBarcode(String barcode);
    Optional<Product> findByProductName(String productName);
}


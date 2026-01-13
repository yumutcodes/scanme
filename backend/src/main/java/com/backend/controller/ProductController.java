package com.backend.controller;

import com.backend.dto.ProductDetailDto;
import com.backend.service.JwtService;
import com.backend.service.ProductService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/products")
public class ProductController {

    private final ProductService productService;
    private final JwtService jwtService;

    public ProductController(ProductService productService, JwtService jwtService) {
        this.productService = productService;
        this.jwtService = jwtService;
    }

    @GetMapping("/search")
    public ResponseEntity<ProductDetailDto> search(@RequestParam("barcode") String barcode,
                                                   @RequestHeader("Authorization") String token) {
        ProductDetailDto dto = productService.getProductDetailsForUser(barcode, jwtService.extractMail(token));
        return ResponseEntity.ok(dto);
    }
}

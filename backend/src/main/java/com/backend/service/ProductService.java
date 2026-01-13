package com.backend.service;

import com.backend.dto.DangerousIngredientDto;
import com.backend.dto.ProductDetailDto;
import com.backend.model.Allergy;
import com.backend.model.Ingredient;
import com.backend.model.Product;
import com.backend.model.User;
import com.backend.repository.DangerousIngredientsRepository;
import com.backend.repository.ProductRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class ProductService {

    private final ProductRepository productRepository;
    private final DangerousIngredientsRepository dangerousIngredientsRepository;
    private final UserService userService;

    public ProductService(ProductRepository productRepository,
                          DangerousIngredientsRepository dangerousIngredientsRepository,
                          UserService userService) {
        this.productRepository = productRepository;
        this.dangerousIngredientsRepository = dangerousIngredientsRepository;
        this.userService = userService;
    }

    public ProductDetailDto getProductDetailsForUser(String barcode, String userEmail) {
        if (barcode == null || barcode.trim().isEmpty()) {
            throw new IllegalArgumentException("barcode must not be blank");
        }

        User user = userService.findUserByEmail(userEmail);

        Product product = productRepository.findWithIngredientsByBarcode(barcode)
            .orElseThrow(() -> new EntityNotFoundException("Product not found!"));

        List<String> ingredientNames = product.getIngredients() == null
            ? Collections.emptyList()
            : product.getIngredients().stream()
                .filter(Objects::nonNull)
                .map(Ingredient::getName)
                .filter(Objects::nonNull)
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .distinct()
                .collect(Collectors.toList());

        List<String> userSelections = user.getAllergies() == null
            ? Collections.emptyList()
            : user.getAllergies().stream()
                .filter(Objects::nonNull)
                .map(Allergy::getName)
                .filter(Objects::nonNull)
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .distinct()
                .collect(Collectors.toList());

        List<DangerousIngredientDto> dangerous = ingredientNames.isEmpty()
            ? Collections.emptyList()
            : dangerousIngredientsRepository.findByNameOfGradientIn(ingredientNames).stream()
                .filter(Objects::nonNull)
                .map(di -> new DangerousIngredientDto(di.getNameOfGradient(), di.getDangerLevel()))
                .sorted(Comparator.comparingInt(DangerousIngredientDto::getDangerLevel).reversed())
                .collect(Collectors.toList());

        return new ProductDetailDto(
            product.getBarcode(),
            product.getProductName(),
            ingredientNames,
            userSelections,
            dangerous
        );
    }
}

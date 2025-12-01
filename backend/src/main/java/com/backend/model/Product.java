package com.backend.model;

import jakarta.persistence.*;

import java.util.List;

@Entity
public class Product extends BaseEntity {
    @Id
    private String barcode;
    private String productName;

    @ManyToMany
    @JoinTable(
        name = "product_ingredients",
        joinColumns = @JoinColumn(name = "product_barcode"),
        inverseJoinColumns = @JoinColumn(name = "ingredient_id")
    )
    private List<Ingredient> ingredients;

    public Product() {
    }

    public Product(String barcode, String productName, List<Ingredient> ingredients) {
        this.barcode = barcode;
        this.productName = productName;
        this.ingredients = ingredients;
    }

    public String getBarcode() {
        return barcode;
    }

    public void setBarcode(String barcode) {
        this.barcode = barcode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public List<Ingredient> getIngredients() {
        return ingredients;
    }

    public void setIngredients(List<Ingredient> ingredients) {
        this.ingredients = ingredients;
    }
}

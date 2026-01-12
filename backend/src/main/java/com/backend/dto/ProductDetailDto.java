package com.backend.dto;

import java.util.List;

public class ProductDetailDto {
    private String barcode;
    private String productName;
    private List<String> ingredients;
    private List<String> userSelections;
    private List<DangerousIngredientDto> dangerousIngredients;

    public ProductDetailDto() {
    }

    public ProductDetailDto(String barcode,
                            String productName,
                            List<String> ingredients,
                            List<String> userSelections,
                            List<DangerousIngredientDto> dangerousIngredients) {
        this.barcode = barcode;
        this.productName = productName;
        this.ingredients = ingredients;
        this.userSelections = userSelections;
        this.dangerousIngredients = dangerousIngredients;
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

    public List<String> getIngredients() {
        return ingredients;
    }

    public void setIngredients(List<String> ingredients) {
        this.ingredients = ingredients;
    }

    public List<String> getUserSelections() {
        return userSelections;
    }

    public void setUserSelections(List<String> userSelections) {
        this.userSelections = userSelections;
    }

    public List<DangerousIngredientDto> getDangerousIngredients() {
        return dangerousIngredients;
    }

    public void setDangerousIngredients(List<DangerousIngredientDto> dangerousIngredients) {
        this.dangerousIngredients = dangerousIngredients;
    }
}

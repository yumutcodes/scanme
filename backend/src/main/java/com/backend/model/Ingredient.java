package com.backend.model;

import jakarta.persistence.*;

import java.util.List;

@Entity
public class Ingredient extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ingredient_id")
    private Long id;
    private String name;

    @ManyToMany
    private List<Product> product;

    public Ingredient() {
    }

    public Ingredient(String name, List<Product> product) {
        this.name = name;
        this.product = product;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Product> getProduct() {
        return product;
    }

    public void setProduct(List<Product> product) {
        this.product = product;
    }
}

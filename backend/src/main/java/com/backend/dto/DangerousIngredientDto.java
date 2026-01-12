package com.backend.dto;

public class DangerousIngredientDto {
    private String name;
    private int dangerLevel;

    public DangerousIngredientDto() {
    }

    public DangerousIngredientDto(String name, int dangerLevel) {
        this.name = name;
        this.dangerLevel = dangerLevel;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getDangerLevel() {
        return dangerLevel;
    }

    public void setDangerLevel(int dangerLevel) {
        this.dangerLevel = dangerLevel;
    }
}


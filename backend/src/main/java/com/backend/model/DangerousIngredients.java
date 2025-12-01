package com.backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity
public class DangerousIngredients extends BaseEntity{

    @Id
    private String nameOfGradient;
    private int dangerLevel; //10 üzerinden diye düşündüm

    public DangerousIngredients() {
    }

    public DangerousIngredients(String nameOfGradient, int dangerLevel) {
        this.nameOfGradient = nameOfGradient;
        this.dangerLevel = dangerLevel;
    }

    public String getNameOfGradient() {
        return nameOfGradient;
    }

    public void setNameOfGradient(String nameOfGradient) {
        this.nameOfGradient = nameOfGradient;
    }

    public int getDangerLevel() {
        return dangerLevel;
    }

    public void setDangerLevel(int dangerLevel) {
        this.dangerLevel = dangerLevel;
    }
}

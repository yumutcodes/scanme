package com.backend.model;

import jakarta.persistence.*;

import java.util.List;

@Entity
public class Allergy extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "allergy_id")
    private Long id;
    private String name;

    @ManyToMany
    private List<User> user;

    public Allergy() {
    }

    public Allergy(String name, List<User> user) {
        this.name = name;
        this.user = user;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<User> getUser() {
        return user;
    }

    public void setUser(List<User> user) {
        this.user = user;
    }
}

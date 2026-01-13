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

    @ManyToMany(mappedBy = "allergies")
    private List<User> users;

    public Allergy() {
    }

    public Allergy(String name, List<User> users) {
        this.name = name;
        this.users = users;
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

    public List<User> getUsers() {
        return users;
    }

    public void setUsers(List<User> users) {
        this.users = users;
    }
}

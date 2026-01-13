package com.backend.repository;

import com.backend.model.Allergy;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AllergyRepository extends JpaRepository<Allergy, Long> {

    Allergy findByName(String name);
}

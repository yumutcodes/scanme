package com.backend.repository;

import com.backend.model.Allergy;
import com.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AllergyRepository extends JpaRepository<Allergy, Long> {

    List<Allergy> findByUserNotContaining(User user);

    Allergy findByName(String name);
}

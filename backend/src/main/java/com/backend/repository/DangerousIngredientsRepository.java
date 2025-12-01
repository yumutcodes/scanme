package com.backend.repository;

import com.backend.model.DangerousIngredients;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DangerousIngredientsRepository extends JpaRepository<DangerousIngredients, String> {
}

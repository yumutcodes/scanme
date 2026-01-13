package com.backend.repository;

import com.backend.model.DangerousIngredients;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface DangerousIngredientsRepository extends JpaRepository<DangerousIngredients, String> {
    List<DangerousIngredients> findByNameOfGradientIn(Collection<String> namesOfGradient);
}

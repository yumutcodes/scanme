package com.backend.service;

import com.backend.model.DangerousIngredients;
import com.backend.repository.DangerousIngredientsRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DangerousIngredientsService {

    private final DangerousIngredientsRepository dangerousGradientsRepository;

    public DangerousIngredientsService(DangerousIngredientsRepository dangerousGradientsRepository) {
        this.dangerousGradientsRepository = dangerousGradientsRepository;
    }

    public List<DangerousIngredients> getAllDangerousGradients() {
        return dangerousGradientsRepository.findAll();
    }
}

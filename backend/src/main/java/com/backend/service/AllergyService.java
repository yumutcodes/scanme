package com.backend.service;

import com.backend.dto.AllergyDto;
import com.backend.dto.converter.AllergyConverter;
import com.backend.model.Allergy;
import com.backend.model.User;
import com.backend.repository.AllergyRepository;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import jakarta.persistence.EntityNotFoundException;

@Service
public class AllergyService {

    private final AllergyRepository allergyRepository;
    private final AllergyConverter allergyConverter;
    private final UserService userService;

    public AllergyService(AllergyRepository allergyRepository, AllergyConverter allergyConverter,
            UserService userService) {
        this.allergyRepository = allergyRepository;
        this.allergyConverter = allergyConverter;
        this.userService = userService;
    }

    public AllergyDto saveAllergyForAUser(AllergyDto allergyDto, String userEmail) {
        User user = userService.findUserByEmail(userEmail);

        Allergy allergy = allergyRepository.findByName(allergyDto.getAllergy_name());
        if (allergy == null) {
            throw new EntityNotFoundException("Allergy not found: " + allergyDto.getAllergy_name());
        }

        if (!user.getAllergies().contains(allergy)) {
            user.getAllergies().add(allergy);
        }

        userService.updateUser(user);

        return new AllergyDto(allergy.getId(), allergy.getName());
    }

    public List<AllergyDto> getAllAllergy(String userEmail) {
        User user = userService.findUserByEmail(userEmail);
        List<Allergy> allergies = user.getAllergies(); // Get user's ACTUAL allergies

        if (allergies == null || allergies.isEmpty()) {
            return Collections.emptyList();
        }

        return allergies.stream()
                .map(allergyConverter::convertToDto)
                .toList();
    }

    public void deleteAAllergyForUser(AllergyDto allergyDto, String userEmail) {
        User user = userService.findUserByEmail(userEmail);
        Allergy allergy = allergyRepository.findByName(allergyDto.getAllergy_name());
        if (allergy == null) {
            throw new EntityNotFoundException("Allergy not found: " + allergyDto.getAllergy_name());
        }
        user.getAllergies().remove(allergy);
        userService.updateUser(user);
    }
}

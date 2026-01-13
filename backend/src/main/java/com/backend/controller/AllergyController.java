package com.backend.controller;

import com.backend.dto.AllergyDto;
import com.backend.service.AllergyService;
import com.backend.service.JwtService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
public class AllergyController {

    private final AllergyService allergyService;
    private final JwtService jwtService;

    public AllergyController(AllergyService allergyService, JwtService jwtService) {
        this.allergyService = allergyService;
        this.jwtService = jwtService;
    }

    @PostMapping("/allergies")
    public ResponseEntity<?> saveAAllergyForUser(@RequestBody AllergyDto allergyDto,
            @RequestHeader("Authorization") String token) {
        return ResponseEntity.ok(allergyService.saveAllergyForAUser(allergyDto, jwtService.extractMail(token)));
    }

    @DeleteMapping("/allergies")
    public ResponseEntity<?> deleteAAllergyForUser(@RequestBody AllergyDto allergyDto,
            @RequestHeader("Authorization") String token) {
        allergyService.deleteAAllergyForUser(allergyDto, jwtService.extractMail(token));
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/allergies")
    public ResponseEntity<List<AllergyDto>> getAllergies(@RequestHeader("Authorization") String token) {
        return ResponseEntity.ok(allergyService.getAllAllergy(jwtService.extractMail(token)));
    }
}

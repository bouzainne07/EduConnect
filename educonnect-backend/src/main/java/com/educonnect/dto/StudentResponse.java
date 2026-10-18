package com.educonnect.dto;

import com.educonnect.enums.NiveauScolaire;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record StudentResponse(
        Long id,
        String firstName,
        String lastName,
        LocalDate dateOfBirth,
        String photoUrl,
        NiveauScolaire niveau,
        String matricule,
        String adresse,
        String telephone,
        String notesDossier,
        boolean active,
        Long userId,
        LocalDateTime createdAt
) {}

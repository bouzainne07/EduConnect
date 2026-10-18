package com.educonnect.dto;

import jakarta.validation.constraints.NotBlank;

public record TeacherRequest(
        @NotBlank String firstName,
        @NotBlank String lastName,
        String specialite,
        String telephone,
        String adresse,
        String diplome,
        Integer anneesExperience,
        Long userId
) {}

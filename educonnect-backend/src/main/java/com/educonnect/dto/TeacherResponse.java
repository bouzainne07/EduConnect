package com.educonnect.dto;

import java.time.LocalDateTime;

public record TeacherResponse(
        Long id,
        String firstName,
        String lastName,
        String specialite,
        String telephone,
        String adresse,
        String photoUrl,
        String diplome,
        Integer anneesExperience,
        boolean active,
        Long userId,
        LocalDateTime createdAt
) {}

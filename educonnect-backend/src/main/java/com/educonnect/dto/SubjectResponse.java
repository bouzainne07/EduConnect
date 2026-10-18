package com.educonnect.dto;

import java.time.LocalDateTime;

public record SubjectResponse(
        Long id,
        String nom,
        String code,
        Double coefficient,
        String description,
        Long teacherId,
        String teacherNom,
        boolean active,
        LocalDateTime createdAt
) {}

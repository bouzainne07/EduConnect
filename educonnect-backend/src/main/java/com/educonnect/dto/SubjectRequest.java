package com.educonnect.dto;

import jakarta.validation.constraints.NotBlank;

public record SubjectRequest(
        @NotBlank String nom,
        String code,
        Double coefficient,
        String description,
        Long teacherId
) {}

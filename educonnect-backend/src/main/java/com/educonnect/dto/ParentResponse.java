package com.educonnect.dto;

import java.time.LocalDateTime;
import java.util.List;

public record ParentResponse(
        Long id,
        String firstName,
        String lastName,
        String telephone,
        String email,
        String adresse,
        String profession,
        boolean active,
        Long userId,
        List<StudentResponse> children,
        LocalDateTime createdAt
) {}

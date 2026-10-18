package com.educonnect.dto;

import jakarta.validation.constraints.NotBlank;
import java.util.List;

public record ParentRequest(
        @NotBlank String firstName,
        @NotBlank String lastName,
        String telephone,
        String email,
        String adresse,
        String profession,
        Long userId,
        List<Long> childrenIds
) {}

package com.educonnect.dto;

import com.educonnect.enums.Role;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        Long userId,
        String email,
        String firstName,
        String lastName,
        Role role,
        String photoUrl
) {}

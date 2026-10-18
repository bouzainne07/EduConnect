package com.educonnect.dto;

import com.educonnect.enums.NiveauScolaire;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record ClasseRequest(
        @NotBlank String nom,
        @NotNull NiveauScolaire niveau,
        String salle,
        Integer capaciteMax,
        Long responsableId
) {}

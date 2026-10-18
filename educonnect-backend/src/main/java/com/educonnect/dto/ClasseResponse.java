package com.educonnect.dto;

import com.educonnect.enums.NiveauScolaire;
import java.time.LocalDateTime;

public record ClasseResponse(
        Long id,
        String nom,
        NiveauScolaire niveau,
        String salle,
        Integer capaciteMax,
        Long responsableId,
        String responsableNom,
        int nombreEleves,
        boolean active,
        LocalDateTime createdAt
) {}

package com.educonnect.dto;

import com.educonnect.enums.NiveauScolaire;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;

import java.time.LocalDate;

public record StudentRequest(

        @NotBlank(message = "Le prénom est obligatoire")
        String firstName,

        @NotBlank(message = "Le nom est obligatoire")
        String lastName,

        @NotNull(message = "La date de naissance est obligatoire")
        @Past(message = "La date de naissance doit être dans le passé")
        LocalDate dateOfBirth,

        @NotNull(message = "Le niveau scolaire est obligatoire")
        NiveauScolaire niveau,

        String matricule,
        String adresse,
        String telephone,
        String notesDossier,
        Long userId  // optionnel
) {}

package com.educonnect.dto;

import com.educonnect.enums.GradeType;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public record GradeRequest(
        @NotNull(message = "L'élève est obligatoire") Long studentId,
        @NotNull(message = "La matière est obligatoire") Long subjectId,
        @NotNull(message = "L'enseignant est obligatoire") Long teacherId,
        @NotNull(message = "Le type d'évaluation est obligatoire") GradeType type,
        @NotNull(message = "La note est obligatoire") Double note,
        Double bareme,
        Double coefficient,
        String appreciation,
        @NotNull(message = "La date d'évaluation est obligatoire") LocalDate dateEvaluation
) {}

package com.educonnect.dto;

import jakarta.validation.constraints.NotNull;
import java.time.DayOfWeek;
import java.time.LocalTime;

public record ScheduleRequest(
        @NotNull(message = "La classe est obligatoire") Long classeId,
        @NotNull(message = "La matière est obligatoire") Long subjectId,
        @NotNull(message = "L'enseignant est obligatoire") Long teacherId,
        String salle,
        @NotNull(message = "Le jour de la semaine est obligatoire") DayOfWeek jourSemaine,
        @NotNull(message = "L'heure de début est obligatoire") LocalTime heureDebut,
        @NotNull(message = "L'heure de fin est obligatoire") LocalTime heureFin
) {}

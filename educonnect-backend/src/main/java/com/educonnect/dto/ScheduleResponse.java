package com.educonnect.dto;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.LocalTime;

public record ScheduleResponse(
        Long id,
        Long classeId,
        String classeNom,
        Long subjectId,
        String subjectNom,
        String subjectCode,
        Long teacherId,
        String teacherNom,
        String salle,
        DayOfWeek jourSemaine,
        LocalTime heureDebut,
        LocalTime heureFin,
        boolean active,
        LocalDateTime createdAt
) {}

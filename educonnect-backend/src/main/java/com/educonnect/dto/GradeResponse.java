package com.educonnect.dto;

import com.educonnect.enums.GradeType;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record GradeResponse(
        Long id,
        Long studentId,
        String studentNom,
        Long subjectId,
        String subjectNom,
        String subjectCode,
        Long teacherId,
        String teacherNom,
        GradeType type,
        Double note,
        Double bareme,
        Double coefficient,
        Double noteSur20,
        String appreciation,
        LocalDate dateEvaluation,
        boolean active,
        LocalDateTime createdAt
) {}

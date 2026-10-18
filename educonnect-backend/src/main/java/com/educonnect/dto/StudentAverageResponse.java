package com.educonnect.dto;

import java.util.List;

public record StudentAverageResponse(
        Long studentId,
        String studentNom,
        Double moyenneGenerale,
        List<SubjectAverageDto> moyennesParMatiere
) {
    public record SubjectAverageDto(
            Long subjectId,
            String subjectNom,
            String subjectCode,
            Double moyenneMatiere,
            Double coefficientMatiere,
            int nombreNotes
    ) {}
}

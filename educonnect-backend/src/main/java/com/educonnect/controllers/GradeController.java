package com.educonnect.controllers;

import com.educonnect.dto.GradeRequest;
import com.educonnect.dto.GradeResponse;
import com.educonnect.dto.StudentAverageResponse;
import com.educonnect.entities.User;
import com.educonnect.services.GradeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/grades")
@RequiredArgsConstructor
@Tag(name = "Notes", description = "Gestion des notes et moyennes")
@SecurityRequirement(name = "bearerAuth")
public class GradeController {

    private final GradeService gradeService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR','ENSEIGNANT')")
    @Operation(summary = "Saisir une note")
    public ResponseEntity<GradeResponse> create(@Valid @RequestBody GradeRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(gradeService.create(req));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir une note par ID")
    public ResponseEntity<GradeResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(gradeService.getById(id));
    }

    @GetMapping("/me")
    @Operation(summary = "Obtenir mes notes")
    public ResponseEntity<List<GradeResponse>> getMyGrades(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(gradeService.getByUser(user));
    }

    @GetMapping("/student/{studentId}")
    @Operation(summary = "Obtenir les notes d'un élève")
    public ResponseEntity<List<GradeResponse>> getByStudent(@PathVariable Long studentId) {
        return ResponseEntity.ok(gradeService.getByStudentId(studentId));
    }

    @GetMapping("/student/{studentId}/averages")
    @Operation(summary = "Obtenir les moyennes et bulletin d'un élève")
    public ResponseEntity<StudentAverageResponse> getStudentAverages(@PathVariable Long studentId) {
        return ResponseEntity.ok(gradeService.calculateStudentAverages(studentId));
    }

    @GetMapping("/teacher/{teacherId}")
    @Operation(summary = "Obtenir les notes saisies par un enseignant")
    public ResponseEntity<List<GradeResponse>> getByTeacher(@PathVariable Long teacherId) {
        return ResponseEntity.ok(gradeService.getByTeacherId(teacherId));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR','ENSEIGNANT')")
    @Operation(summary = "Modifier une note")
    public ResponseEntity<GradeResponse> update(@PathVariable Long id, @Valid @RequestBody GradeRequest req) {
        return ResponseEntity.ok(gradeService.update(id, req));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR','ENSEIGNANT')")
    @Operation(summary = "Supprimer une note (soft delete)")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        gradeService.delete(id);
        return ResponseEntity.noContent().build();
    }
}

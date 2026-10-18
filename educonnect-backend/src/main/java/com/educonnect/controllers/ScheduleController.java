package com.educonnect.controllers;

import com.educonnect.dto.ScheduleRequest;
import com.educonnect.dto.ScheduleResponse;
import com.educonnect.entities.User;
import com.educonnect.services.ScheduleService;
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
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
@Tag(name = "Emploi du temps", description = "Gestion des emplois du temps")
@SecurityRequirement(name = "bearerAuth")
public class ScheduleController {

    private final ScheduleService scheduleService;

    @GetMapping("/me")
    @Operation(summary = "Obtenir mon emploi du temps")
    public ResponseEntity<List<ScheduleResponse>> getMySchedule(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(scheduleService.getByUser(user));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR')")
    @Operation(summary = "Créer un créneau d'emploi du temps")
    public ResponseEntity<ScheduleResponse> create(@Valid @RequestBody ScheduleRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(scheduleService.create(req));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un créneau par ID")
    public ResponseEntity<ScheduleResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(scheduleService.getById(id));
    }

    @GetMapping("/classe/{classeId}")
    @Operation(summary = "Obtenir l'emploi du temps d'une classe")
    public ResponseEntity<List<ScheduleResponse>> getByClasse(@PathVariable Long classeId) {
        return ResponseEntity.ok(scheduleService.getByClasseId(classeId));
    }

    @GetMapping("/teacher/{teacherId}")
    @Operation(summary = "Obtenir l'emploi du temps d'un enseignant")
    public ResponseEntity<List<ScheduleResponse>> getByTeacher(@PathVariable Long teacherId) {
        return ResponseEntity.ok(scheduleService.getByTeacherId(teacherId));
    }

    @GetMapping("/student/{studentId}")
    @Operation(summary = "Obtenir l'emploi du temps d'un élève")
    public ResponseEntity<List<ScheduleResponse>> getByStudent(@PathVariable Long studentId) {
        return ResponseEntity.ok(scheduleService.getByStudentId(studentId));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR')")
    @Operation(summary = "Modifier un créneau")
    public ResponseEntity<ScheduleResponse> update(@PathVariable Long id, @Valid @RequestBody ScheduleRequest req) {
        return ResponseEntity.ok(scheduleService.update(id, req));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR')")
    @Operation(summary = "Supprimer un créneau (soft delete)")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        scheduleService.delete(id);
        return ResponseEntity.noContent().build();
    }
}

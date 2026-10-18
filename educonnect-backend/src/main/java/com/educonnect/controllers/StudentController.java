package com.educonnect.controllers;

import com.educonnect.dto.StudentRequest;
import com.educonnect.dto.StudentResponse;
import com.educonnect.enums.NiveauScolaire;
import com.educonnect.services.StudentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
@Tag(name = "Élèves", description = "Gestion des élèves")
@SecurityRequirement(name = "bearerAuth")
public class StudentController {

    private final StudentService studentService;

    @PostMapping
    @Operation(summary = "Créer un élève")
    @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTEUR')")
    public ResponseEntity<StudentResponse> create(@Valid @RequestBody StudentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(studentService.create(request));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un élève par ID")
    @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTEUR', 'ENSEIGNANT')")
    public ResponseEntity<StudentResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(studentService.getById(id));
    }

    @GetMapping
    @Operation(summary = "Lister tous les élèves (paginé)")
    @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTEUR', 'ENSEIGNANT')")
    public ResponseEntity<Page<StudentResponse>> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "lastName") String sortBy
    ) {
        return ResponseEntity.ok(
                studentService.getAll(PageRequest.of(page, size, Sort.by(sortBy)))
        );
    }

    @GetMapping("/niveau/{niveau}")
    @Operation(summary = "Lister les élèves par niveau")
    @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTEUR', 'ENSEIGNANT')")
    public ResponseEntity<Page<StudentResponse>> getByNiveau(
            @PathVariable NiveauScolaire niveau,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(
                studentService.getByNiveau(niveau, PageRequest.of(page, size, Sort.by("lastName")))
        );
    }

    @GetMapping("/search")
    @Operation(summary = "Rechercher un élève par nom/prénom/matricule")
    @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTEUR', 'ENSEIGNANT')")
    public ResponseEntity<Page<StudentResponse>> search(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(
                studentService.search(q, PageRequest.of(page, size))
        );
    }

    @PutMapping("/{id}")
    @Operation(summary = "Modifier un élève")
    @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTEUR')")
    public ResponseEntity<StudentResponse> update(
            @PathVariable Long id,
            @Valid @RequestBody StudentRequest request
    ) {
        return ResponseEntity.ok(studentService.update(id, request));
    }

    @PatchMapping("/{id}/photo")
    @Operation(summary = "Mettre à jour la photo d'un élève")
    @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTEUR')")
    public ResponseEntity<StudentResponse> updatePhoto(
            @PathVariable Long id,
            @RequestParam String photoUrl
    ) {
        return ResponseEntity.ok(studentService.updatePhoto(id, photoUrl));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un élève (soft delete)")
    @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTEUR')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        studentService.delete(id);
        return ResponseEntity.noContent().build();
    }
}

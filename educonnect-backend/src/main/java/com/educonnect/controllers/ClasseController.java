package com.educonnect.controllers;

import com.educonnect.dto.ClasseRequest;
import com.educonnect.dto.ClasseResponse;
import com.educonnect.services.ClasseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/classes")
@RequiredArgsConstructor
@Tag(name = "Classes")
@SecurityRequirement(name = "bearerAuth")
public class ClasseController {

    private final ClasseService classeService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR')")
    @Operation(summary = "Créer une classe")
    public ResponseEntity<ClasseResponse> create(@Valid @RequestBody ClasseRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(classeService.create(req));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir une classe")
    public ResponseEntity<ClasseResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(classeService.getById(id));
    }

    @GetMapping
    @Operation(summary = "Lister toutes les classes")
    public ResponseEntity<List<ClasseResponse>> getAll() {
        return ResponseEntity.ok(classeService.getAll());
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR')")
    @Operation(summary = "Modifier une classe")
    public ResponseEntity<ClasseResponse> update(@PathVariable Long id, @Valid @RequestBody ClasseRequest req) {
        return ResponseEntity.ok(classeService.update(id, req));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR')")
    @Operation(summary = "Supprimer une classe")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        classeService.delete(id);
        return ResponseEntity.noContent().build();
    }
}

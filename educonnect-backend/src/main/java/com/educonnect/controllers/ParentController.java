package com.educonnect.controllers;

import com.educonnect.dto.ParentRequest;
import com.educonnect.dto.ParentResponse;
import com.educonnect.services.ParentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/parents")
@RequiredArgsConstructor
@Tag(name = "Parents")
@SecurityRequirement(name = "bearerAuth")
public class ParentController {

    private final ParentService parentService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR')")
    @Operation(summary = "Créer un parent")
    public ResponseEntity<ParentResponse> create(@Valid @RequestBody ParentRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(parentService.create(req));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un parent par ID")
    public ResponseEntity<ParentResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(parentService.getById(id));
    }

    @GetMapping
    @Operation(summary = "Lister les parents")
    public ResponseEntity<Page<ParentResponse>> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(parentService.getAll(PageRequest.of(page, size)));
    }

    @GetMapping("/student/{studentId}")
    @Operation(summary = "Parents d'un élève")
    public ResponseEntity<List<ParentResponse>> getByStudent(@PathVariable Long studentId) {
        return ResponseEntity.ok(parentService.getByStudentId(studentId));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR')")
    @Operation(summary = "Modifier un parent")
    public ResponseEntity<ParentResponse> update(@PathVariable Long id, @Valid @RequestBody ParentRequest req) {
        return ResponseEntity.ok(parentService.update(id, req));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRECTEUR')")
    @Operation(summary = "Supprimer un parent")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        parentService.delete(id);
        return ResponseEntity.noContent().build();
    }
}

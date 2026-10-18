package com.educonnect.services;

import com.educonnect.dto.ClasseRequest;
import com.educonnect.dto.ClasseResponse;
import com.educonnect.entities.Classe;
import com.educonnect.entities.Teacher;
import com.educonnect.exceptions.AppException;
import com.educonnect.repositories.ClasseRepository;
import com.educonnect.repositories.TeacherRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ClasseService {

    private final ClasseRepository classeRepository;
    private final TeacherRepository teacherRepository;

    @Transactional
    public ClasseResponse create(ClasseRequest req) {
        if (classeRepository.existsByNom(req.nom()))
            throw new AppException("Une classe avec ce nom existe déjà", HttpStatus.CONFLICT);
        Classe c = Classe.builder()
                .nom(req.nom()).niveau(req.niveau()).salle(req.salle())
                .capaciteMax(req.capaciteMax())
                .responsable(resolveTeacher(req.responsableId()))
                .build();
        return toResponse(classeRepository.save(c));
    }

    @Transactional(readOnly = true)
    public ClasseResponse getById(Long id) { return toResponse(findById(id)); }

    @Transactional(readOnly = true)
    public List<ClasseResponse> getAll() {
        return classeRepository.findByActiveTrue().stream().map(this::toResponse).toList();
    }

    @Transactional
    public ClasseResponse update(Long id, ClasseRequest req) {
        Classe c = findById(id);
        c.setNom(req.nom()); c.setSalle(req.salle()); c.setNiveau(req.niveau());
        c.setCapaciteMax(req.capaciteMax());
        c.setResponsable(resolveTeacher(req.responsableId()));
        return toResponse(classeRepository.save(c));
    }

    @Transactional
    public void delete(Long id) {
        Classe c = findById(id);
        c.setActive(false);
        classeRepository.save(c);
    }

    private Classe findById(Long id) {
        return classeRepository.findById(id)
                .orElseThrow(() -> new AppException("Classe non trouvée", HttpStatus.NOT_FOUND));
    }

    private Teacher resolveTeacher(Long id) {
        if (id == null) return null;
        return teacherRepository.findById(id)
                .orElseThrow(() -> new AppException("Enseignant non trouvé", HttpStatus.NOT_FOUND));
    }

    private ClasseResponse toResponse(Classe c) {
        return new ClasseResponse(c.getId(), c.getNom(), c.getNiveau(), c.getSalle(),
                c.getCapaciteMax(),
                c.getResponsable() != null ? c.getResponsable().getId() : null,
                c.getResponsable() != null ? c.getResponsable().getFirstName() + " " + c.getResponsable().getLastName() : null,
                c.getStudents().size(), c.isActive(), c.getCreatedAt());
    }
}

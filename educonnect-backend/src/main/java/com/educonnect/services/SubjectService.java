package com.educonnect.services;

import com.educonnect.dto.SubjectRequest;
import com.educonnect.dto.SubjectResponse;
import com.educonnect.entities.Subject;
import com.educonnect.entities.Teacher;
import com.educonnect.exceptions.AppException;
import com.educonnect.repositories.SubjectRepository;
import com.educonnect.repositories.TeacherRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SubjectService {

    private final SubjectRepository subjectRepository;
    private final TeacherRepository teacherRepository;

    @Transactional
    public SubjectResponse create(SubjectRequest req) {
        Subject s = Subject.builder()
                .nom(req.nom()).code(req.code()).coefficient(req.coefficient())
                .description(req.description())
                .teacher(resolveTeacher(req.teacherId()))
                .build();
        return toResponse(subjectRepository.save(s));
    }

    @Transactional(readOnly = true)
    public SubjectResponse getById(Long id) { return toResponse(findById(id)); }

    @Transactional(readOnly = true)
    public List<SubjectResponse> getAll() {
        return subjectRepository.findByActiveTrue().stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public List<SubjectResponse> getByTeacher(Long teacherId) {
        return subjectRepository.findByTeacherIdAndActiveTrue(teacherId).stream().map(this::toResponse).toList();
    }

    @Transactional
    public SubjectResponse update(Long id, SubjectRequest req) {
        Subject s = findById(id);
        s.setNom(req.nom()); s.setCode(req.code()); s.setCoefficient(req.coefficient());
        s.setDescription(req.description()); s.setTeacher(resolveTeacher(req.teacherId()));
        return toResponse(subjectRepository.save(s));
    }

    @Transactional
    public void delete(Long id) {
        Subject s = findById(id);
        s.setActive(false);
        subjectRepository.save(s);
    }

    private Subject findById(Long id) {
        return subjectRepository.findById(id)
                .orElseThrow(() -> new AppException("Matière non trouvée", HttpStatus.NOT_FOUND));
    }

    private Teacher resolveTeacher(Long id) {
        if (id == null) return null;
        return teacherRepository.findById(id)
                .orElseThrow(() -> new AppException("Enseignant non trouvé", HttpStatus.NOT_FOUND));
    }

    private SubjectResponse toResponse(Subject s) {
        return new SubjectResponse(s.getId(), s.getNom(), s.getCode(), s.getCoefficient(),
                s.getDescription(),
                s.getTeacher() != null ? s.getTeacher().getId() : null,
                s.getTeacher() != null ? s.getTeacher().getFirstName() + " " + s.getTeacher().getLastName() : null,
                s.isActive(), s.getCreatedAt());
    }
}

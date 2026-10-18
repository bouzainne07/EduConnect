package com.educonnect.services;

import com.educonnect.dto.ParentRequest;
import com.educonnect.dto.ParentResponse;
import com.educonnect.dto.StudentResponse;
import com.educonnect.entities.Parent;
import com.educonnect.entities.Student;
import com.educonnect.entities.User;
import com.educonnect.exceptions.AppException;
import com.educonnect.repositories.ParentRepository;
import com.educonnect.repositories.StudentRepository;
import com.educonnect.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ParentService {

    private final ParentRepository parentRepository;
    private final StudentRepository studentRepository;
    private final UserRepository userRepository;

    @Transactional
    public ParentResponse create(ParentRequest req) {
        Parent p = Parent.builder()
                .firstName(req.firstName()).lastName(req.lastName())
                .telephone(req.telephone()).email(req.email())
                .adresse(req.adresse()).profession(req.profession())
                .user(resolveUser(req.userId()))
                .children(resolveChildren(req.childrenIds()))
                .build();
        return toResponse(parentRepository.save(p));
    }

    @Transactional(readOnly = true)
    public ParentResponse getById(Long id) { return toResponse(findById(id)); }

    @Transactional(readOnly = true)
    public Page<ParentResponse> getAll(Pageable p) {
        return parentRepository.findByActiveTrue(p).map(this::toResponse);
    }

    @Transactional(readOnly = true)
    public List<ParentResponse> getByStudentId(Long studentId) {
        return parentRepository.findByStudentId(studentId).stream().map(this::toResponse).toList();
    }

    @Transactional
    public ParentResponse update(Long id, ParentRequest req) {
        Parent p = findById(id);
        p.setFirstName(req.firstName()); p.setLastName(req.lastName());
        p.setTelephone(req.telephone()); p.setEmail(req.email());
        p.setAdresse(req.adresse()); p.setProfession(req.profession());
        if (req.childrenIds() != null) p.setChildren(resolveChildren(req.childrenIds()));
        return toResponse(parentRepository.save(p));
    }

    @Transactional
    public void delete(Long id) {
        Parent p = findById(id);
        p.setActive(false);
        parentRepository.save(p);
    }

    private Parent findById(Long id) {
        return parentRepository.findById(id)
                .orElseThrow(() -> new AppException("Parent non trouvé", HttpStatus.NOT_FOUND));
    }

    private User resolveUser(Long userId) {
        if (userId == null) return null;
        return userRepository.findById(userId)
                .orElseThrow(() -> new AppException("Utilisateur non trouvé", HttpStatus.NOT_FOUND));
    }

    private List<Student> resolveChildren(List<Long> ids) {
        if (ids == null || ids.isEmpty()) return new ArrayList<>();
        return studentRepository.findAllById(ids);
    }

    private StudentResponse studentToResponse(Student s) {
        return new StudentResponse(s.getId(), s.getFirstName(), s.getLastName(),
                s.getDateOfBirth(), s.getPhotoUrl(), s.getNiveau(), s.getMatricule(),
                s.getAdresse(), s.getTelephone(), s.getNotesDossier(), s.isActive(),
                s.getUser() != null ? s.getUser().getId() : null, s.getCreatedAt());
    }

    private ParentResponse toResponse(Parent p) {
        return new ParentResponse(p.getId(), p.getFirstName(), p.getLastName(),
                p.getTelephone(), p.getEmail(), p.getAdresse(), p.getProfession(),
                p.isActive(), p.getUser() != null ? p.getUser().getId() : null,
                p.getChildren().stream().map(this::studentToResponse).toList(),
                p.getCreatedAt());
    }
}

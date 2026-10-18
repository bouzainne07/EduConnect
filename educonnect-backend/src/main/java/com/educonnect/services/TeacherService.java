package com.educonnect.services;

import com.educonnect.dto.TeacherRequest;
import com.educonnect.dto.TeacherResponse;
import com.educonnect.entities.Teacher;
import com.educonnect.entities.User;
import com.educonnect.exceptions.AppException;
import com.educonnect.repositories.TeacherRepository;
import com.educonnect.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TeacherService {

    private final TeacherRepository teacherRepository;
    private final UserRepository userRepository;

    @Transactional
    public TeacherResponse create(TeacherRequest req) {
        Teacher t = Teacher.builder()
                .firstName(req.firstName()).lastName(req.lastName())
                .specialite(req.specialite()).telephone(req.telephone())
                .adresse(req.adresse()).diplome(req.diplome())
                .anneesExperience(req.anneesExperience())
                .user(resolveUser(req.userId()))
                .build();
        return toResponse(teacherRepository.save(t));
    }

    @Transactional(readOnly = true)
    public TeacherResponse getById(Long id) { return toResponse(findById(id)); }

    @Transactional(readOnly = true)
    public Page<TeacherResponse> getAll(Pageable p) {
        return teacherRepository.findByActiveTrue(p).map(this::toResponse);
    }

    @Transactional(readOnly = true)
    public Page<TeacherResponse> search(String q, Pageable p) {
        return teacherRepository.search(q, p).map(this::toResponse);
    }

    @Transactional
    public TeacherResponse update(Long id, TeacherRequest req) {
        Teacher t = findById(id);
        t.setFirstName(req.firstName()); t.setLastName(req.lastName());
        t.setSpecialite(req.specialite()); t.setTelephone(req.telephone());
        t.setAdresse(req.adresse()); t.setDiplome(req.diplome());
        t.setAnneesExperience(req.anneesExperience());
        if (req.userId() != null) t.setUser(resolveUser(req.userId()));
        return toResponse(teacherRepository.save(t));
    }

    @Transactional
    public void delete(Long id) {
        Teacher t = findById(id);
        t.setActive(false);
        teacherRepository.save(t);
    }

    private Teacher findById(Long id) {
        return teacherRepository.findById(id)
                .orElseThrow(() -> new AppException("Enseignant non trouvé", HttpStatus.NOT_FOUND));
    }

    private User resolveUser(Long userId) {
        if (userId == null) return null;
        return userRepository.findById(userId)
                .orElseThrow(() -> new AppException("Utilisateur non trouvé", HttpStatus.NOT_FOUND));
    }

    private TeacherResponse toResponse(Teacher t) {
        return new TeacherResponse(t.getId(), t.getFirstName(), t.getLastName(),
                t.getSpecialite(), t.getTelephone(), t.getAdresse(), t.getPhotoUrl(),
                t.getDiplome(), t.getAnneesExperience(), t.isActive(),
                t.getUser() != null ? t.getUser().getId() : null, t.getCreatedAt());
    }
}

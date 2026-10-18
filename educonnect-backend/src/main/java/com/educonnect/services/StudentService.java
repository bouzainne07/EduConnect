package com.educonnect.services;

import com.educonnect.dto.StudentRequest;
import com.educonnect.dto.StudentResponse;
import com.educonnect.entities.Student;
import com.educonnect.entities.User;
import com.educonnect.enums.NiveauScolaire;
import com.educonnect.exceptions.AppException;
import com.educonnect.repositories.StudentRepository;
import com.educonnect.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class StudentService {

    private final StudentRepository studentRepository;
    private final UserRepository userRepository;

    @Transactional
    public StudentResponse create(StudentRequest request) {
        if (request.matricule() != null && studentRepository.existsByMatricule(request.matricule())) {
            throw new AppException("Ce matricule est déjà utilisé", HttpStatus.CONFLICT);
        }

        User user = null;
        if (request.userId() != null) {
            user = userRepository.findById(request.userId())
                    .orElseThrow(() -> new AppException("Utilisateur non trouvé", HttpStatus.NOT_FOUND));
        }

        Student student = Student.builder()
                .firstName(request.firstName())
                .lastName(request.lastName())
                .dateOfBirth(request.dateOfBirth())
                .niveau(request.niveau())
                .matricule(request.matricule())
                .adresse(request.adresse())
                .telephone(request.telephone())
                .notesDossier(request.notesDossier())
                .user(user)
                .active(true)
                .build();

        return toResponse(studentRepository.save(student));
    }

    @Transactional(readOnly = true)
    public StudentResponse getById(Long id) {
        return toResponse(findById(id));
    }

    @Transactional(readOnly = true)
    public Page<StudentResponse> getAll(Pageable pageable) {
        return studentRepository.findByActiveTrue(pageable).map(this::toResponse);
    }

    @Transactional(readOnly = true)
    public Page<StudentResponse> getByNiveau(NiveauScolaire niveau, Pageable pageable) {
        return studentRepository.findByNiveauAndActiveTrue(niveau, pageable).map(this::toResponse);
    }

    @Transactional(readOnly = true)
    public Page<StudentResponse> search(String query, Pageable pageable) {
        return studentRepository.searchStudents(query, pageable).map(this::toResponse);
    }

    @Transactional
    public StudentResponse update(Long id, StudentRequest request) {
        Student student = findById(id);

        if (request.matricule() != null
                && !request.matricule().equals(student.getMatricule())
                && studentRepository.existsByMatricule(request.matricule())) {
            throw new AppException("Ce matricule est déjà utilisé", HttpStatus.CONFLICT);
        }

        student.setFirstName(request.firstName());
        student.setLastName(request.lastName());
        student.setDateOfBirth(request.dateOfBirth());
        student.setNiveau(request.niveau());
        student.setMatricule(request.matricule());
        student.setAdresse(request.adresse());
        student.setTelephone(request.telephone());
        student.setNotesDossier(request.notesDossier());

        if (request.userId() != null) {
            User user = userRepository.findById(request.userId())
                    .orElseThrow(() -> new AppException("Utilisateur non trouvé", HttpStatus.NOT_FOUND));
            student.setUser(user);
        }

        return toResponse(studentRepository.save(student));
    }

    @Transactional
    public StudentResponse updatePhoto(Long id, String photoUrl) {
        Student student = findById(id);
        student.setPhotoUrl(photoUrl);
        return toResponse(studentRepository.save(student));
    }

    @Transactional
    public void delete(Long id) {
        Student student = findById(id);
        // Soft delete
        student.setActive(false);
        studentRepository.save(student);
    }

    // --- Helpers ---

    private Student findById(Long id) {
        return studentRepository.findById(id)
                .orElseThrow(() -> new AppException("Élève non trouvé", HttpStatus.NOT_FOUND));
    }

    private StudentResponse toResponse(Student s) {
        return new StudentResponse(
                s.getId(),
                s.getFirstName(),
                s.getLastName(),
                s.getDateOfBirth(),
                s.getPhotoUrl(),
                s.getNiveau(),
                s.getMatricule(),
                s.getAdresse(),
                s.getTelephone(),
                s.getNotesDossier(),
                s.isActive(),
                s.getUser() != null ? s.getUser().getId() : null,
                s.getCreatedAt()
        );
    }
}

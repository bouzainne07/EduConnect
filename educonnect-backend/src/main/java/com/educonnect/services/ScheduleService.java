package com.educonnect.services;

import com.educonnect.dto.ScheduleRequest;
import com.educonnect.dto.ScheduleResponse;
import com.educonnect.entities.*;
import com.educonnect.exceptions.AppException;
import com.educonnect.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final ClasseRepository classeRepository;
    private final SubjectRepository subjectRepository;
    private final TeacherRepository teacherRepository;
    private final StudentRepository studentRepository;
    private final ParentRepository parentRepository;

    @Transactional
    public ScheduleResponse create(ScheduleRequest req) {
        Classe classe = classeRepository.findById(req.classeId())
                .orElseThrow(() -> new AppException("Classe non trouvée", HttpStatus.NOT_FOUND));

        Subject subject = subjectRepository.findById(req.subjectId())
                .orElseThrow(() -> new AppException("Matière non trouvée", HttpStatus.NOT_FOUND));

        Teacher teacher = teacherRepository.findById(req.teacherId())
                .orElseThrow(() -> new AppException("Enseignant non trouvé", HttpStatus.NOT_FOUND));

        Schedule schedule = Schedule.builder()
                .classe(classe)
                .subject(subject)
                .teacher(teacher)
                .salle(req.salle())
                .jourSemaine(req.jourSemaine())
                .heureDebut(req.heureDebut())
                .heureFin(req.heureFin())
                .active(true)
                .build();

        return toResponse(scheduleRepository.save(schedule));
    }

    @Transactional(readOnly = true)
    public ScheduleResponse getById(Long id) {
        return toResponse(findById(id));
    }

    @Transactional(readOnly = true)
    public List<ScheduleResponse> getByClasseId(Long classeId) {
        return scheduleRepository.findByClasseIdAndActiveTrue(classeId)
                .stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public List<ScheduleResponse> getByTeacherId(Long teacherId) {
        return scheduleRepository.findByTeacherIdAndActiveTrue(teacherId)
                .stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public List<ScheduleResponse> getByStudentId(Long studentId) {
        return scheduleRepository.findByStudentId(studentId)
                .stream().map(this::toResponse).toList();
    }

    @Transactional
    public ScheduleResponse update(Long id, ScheduleRequest req) {
        Schedule schedule = findById(id);

        Classe classe = classeRepository.findById(req.classeId())
                .orElseThrow(() -> new AppException("Classe non trouvée", HttpStatus.NOT_FOUND));

        Subject subject = subjectRepository.findById(req.subjectId())
                .orElseThrow(() -> new AppException("Matière non trouvée", HttpStatus.NOT_FOUND));

        Teacher teacher = teacherRepository.findById(req.teacherId())
                .orElseThrow(() -> new AppException("Enseignant non trouvé", HttpStatus.NOT_FOUND));

        schedule.setClasse(classe);
        schedule.setSubject(subject);
        schedule.setTeacher(teacher);
        schedule.setSalle(req.salle());
        schedule.setJourSemaine(req.jourSemaine());
        schedule.setHeureDebut(req.heureDebut());
        schedule.setHeureFin(req.heureFin());

        return toResponse(scheduleRepository.save(schedule));
    }

    @Transactional
    public void delete(Long id) {
        Schedule schedule = findById(id);
        schedule.setActive(false);
        scheduleRepository.save(schedule);
    }

    private Schedule findById(Long id) {
        return scheduleRepository.findById(id)
                .orElseThrow(() -> new AppException("Créneau d'emploi du temps non trouvé", HttpStatus.NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public List<ScheduleResponse> getByUser(User user) {
        switch (user.getRole()) {
            case ELEVE:
                Student student = studentRepository.findByUserIdAndActiveTrue(user.getId())
                        .orElseThrow(() -> new AppException("Élève non trouvé", HttpStatus.NOT_FOUND));
                if (student.getClasse() == null) {
                    return List.of();
                }
                return getByClasseId(student.getClasse().getId());
            case ENSEIGNANT:
                Teacher teacher = teacherRepository.findByUserIdAndActiveTrue(user.getId())
                        .orElseThrow(() -> new AppException("Enseignant non trouvé", HttpStatus.NOT_FOUND));
                return getByTeacherId(teacher.getId());
            case PARENT:
                Parent parent = parentRepository.findByUserIdAndActiveTrue(user.getId())
                        .orElseThrow(() -> new AppException("Parent non trouvé", HttpStatus.NOT_FOUND));
                return parent.getChildren().stream()
                        .filter(Student::isActive)
                        .filter(s -> s.getClasse() != null)
                        .flatMap(s -> scheduleRepository.findByClasseIdAndActiveTrue(s.getClasse().getId()).stream())
                        .map(this::toResponse)
                        .distinct()
                        .toList();
            case ADMIN:
            case DIRECTEUR:
            case SURVEILLANT:
            default:
                return scheduleRepository.findAll().stream()
                        .filter(Schedule::isActive)
                        .map(this::toResponse)
                        .toList();
        }
    }

    private ScheduleResponse toResponse(Schedule s) {
        return new ScheduleResponse(
                s.getId(),
                s.getClasse().getId(),
                s.getClasse().getNom(),
                s.getSubject().getId(),
                s.getSubject().getNom(),
                s.getSubject().getCode(),
                s.getTeacher().getId(),
                s.getTeacher().getFirstName() + " " + s.getTeacher().getLastName(),
                s.getSalle(),
                s.getJourSemaine(),
                s.getHeureDebut(),
                s.getHeureFin(),
                s.isActive(),
                s.getCreatedAt()
        );
    }
}

package com.educonnect.services;

import com.educonnect.dto.GradeRequest;
import com.educonnect.dto.GradeResponse;
import com.educonnect.dto.StudentAverageResponse;
import com.educonnect.entities.*;
import com.educonnect.exceptions.AppException;
import com.educonnect.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GradeService {

    private final GradeRepository gradeRepository;
    private final StudentRepository studentRepository;
    private final SubjectRepository subjectRepository;
    private final TeacherRepository teacherRepository;
    private final ParentRepository parentRepository;

    @Transactional
    public GradeResponse create(GradeRequest req) {
        Student student = studentRepository.findById(req.studentId())
                .orElseThrow(() -> new AppException("Élève non trouvé", HttpStatus.NOT_FOUND));

        Subject subject = subjectRepository.findById(req.subjectId())
                .orElseThrow(() -> new AppException("Matière non trouvée", HttpStatus.NOT_FOUND));

        Teacher teacher = teacherRepository.findById(req.teacherId())
                .orElseThrow(() -> new AppException("Enseignant non trouvé", HttpStatus.NOT_FOUND));

        double bareme = (req.bareme() != null && req.bareme() > 0) ? req.bareme() : 20.0;
        double coef = (req.coefficient() != null && req.coefficient() > 0) ? req.coefficient() : 1.0;

        Grade grade = Grade.builder()
                .student(student)
                .subject(subject)
                .teacher(teacher)
                .type(req.type())
                .note(req.note())
                .bareme(bareme)
                .coefficient(coef)
                .appreciation(req.appreciation())
                .dateEvaluation(req.dateEvaluation())
                .active(true)
                .build();

        return toResponse(gradeRepository.save(grade));
    }

    @Transactional(readOnly = true)
    public GradeResponse getById(Long id) {
        return toResponse(findById(id));
    }

    @Transactional(readOnly = true)
    public List<GradeResponse> getByStudentId(Long studentId) {
        return gradeRepository.findByStudentIdAndActiveTrue(studentId)
                .stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public List<GradeResponse> getByTeacherId(Long teacherId) {
        return gradeRepository.findByTeacherIdAndActiveTrue(teacherId)
                .stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public StudentAverageResponse calculateStudentAverages(Long studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new AppException("Élève non trouvé", HttpStatus.NOT_FOUND));

        List<Grade> grades = gradeRepository.findByStudentIdAndActiveTrue(studentId);

        if (grades.isEmpty()) {
            return new StudentAverageResponse(studentId, student.getFirstName() + " " + student.getLastName(), null, List.of());
        }

        Map<Subject, List<Grade>> gradesBySubject = grades.stream()
                .collect(Collectors.groupingBy(Grade::getSubject));

        List<StudentAverageResponse.SubjectAverageDto> subjectAverages = new ArrayList<>();
        double totalWeightedAverage = 0.0;
        double totalSubjectCoefficients = 0.0;

        for (Map.Entry<Subject, List<Grade>> entry : gradesBySubject.entrySet()) {
            Subject subject = entry.getKey();
            List<Grade> subjectGrades = entry.getValue();

            double sumWeightedNotes = 0.0;
            double sumCoefs = 0.0;

            for (Grade g : subjectGrades) {
                double note20 = (g.getNote() / g.getBareme()) * 20.0;
                sumWeightedNotes += note20 * g.getCoefficient();
                sumCoefs += g.getCoefficient();
            }

            double moySubject = sumCoefs > 0 ? (sumWeightedNotes / sumCoefs) : 0.0;
            double roundedSubjectMoy = round(moySubject);
            double subjectCoef = (subject.getCoefficient() != null && subject.getCoefficient() > 0) ? subject.getCoefficient() : 1.0;

            subjectAverages.add(new StudentAverageResponse.SubjectAverageDto(
                    subject.getId(),
                    subject.getNom(),
                    subject.getCode(),
                    roundedSubjectMoy,
                    subjectCoef,
                    subjectGrades.size()
            ));

            totalWeightedAverage += roundedSubjectMoy * subjectCoef;
            totalSubjectCoefficients += subjectCoef;
        }

        Double generalAverage = totalSubjectCoefficients > 0 ? round(totalWeightedAverage / totalSubjectCoefficients) : null;

        return new StudentAverageResponse(
                studentId,
                student.getFirstName() + " " + student.getLastName(),
                generalAverage,
                subjectAverages
        );
    }

    @Transactional(readOnly = true)
    public List<GradeResponse> getByUser(User user) {
        switch (user.getRole()) {
            case ELEVE:
                Student student = studentRepository.findByUserIdAndActiveTrue(user.getId())
                        .orElseThrow(() -> new AppException("Élève non trouvé", HttpStatus.NOT_FOUND));
                return getByStudentId(student.getId());

            case ENSEIGNANT:
                Teacher teacher = teacherRepository.findByUserIdAndActiveTrue(user.getId())
                        .orElseThrow(() -> new AppException("Enseignant non trouvé", HttpStatus.NOT_FOUND));
                return getByTeacherId(teacher.getId());

            case PARENT:
                Parent parent = parentRepository.findByUserIdAndActiveTrue(user.getId())
                        .orElseThrow(() -> new AppException("Parent non trouvé", HttpStatus.NOT_FOUND));
                return parent.getChildren().stream()
                        .filter(Student::isActive)
                        .flatMap(s -> gradeRepository.findByStudentIdAndActiveTrue(s.getId()).stream())
                        .map(this::toResponse)
                        .distinct()
                        .toList();

            case ADMIN:
            case DIRECTEUR:
            case SURVEILLANT:
            default:
                return gradeRepository.findAll().stream()
                        .filter(Grade::isActive)
                        .map(this::toResponse)
                        .toList();
        }
    }

    @Transactional
    public GradeResponse update(Long id, GradeRequest req) {
        Grade grade = findById(id);

        Student student = studentRepository.findById(req.studentId())
                .orElseThrow(() -> new AppException("Élève non trouvé", HttpStatus.NOT_FOUND));

        Subject subject = subjectRepository.findById(req.subjectId())
                .orElseThrow(() -> new AppException("Matière non trouvée", HttpStatus.NOT_FOUND));

        Teacher teacher = teacherRepository.findById(req.teacherId())
                .orElseThrow(() -> new AppException("Enseignant non trouvé", HttpStatus.NOT_FOUND));

        grade.setStudent(student);
        grade.setSubject(subject);
        grade.setTeacher(teacher);
        grade.setType(req.type());
        grade.setNote(req.note());

        if (req.bareme() != null && req.bareme() > 0) grade.setBareme(req.bareme());
        if (req.coefficient() != null && req.coefficient() > 0) grade.setCoefficient(req.coefficient());

        grade.setAppreciation(req.appreciation());
        grade.setDateEvaluation(req.dateEvaluation());

        return toResponse(gradeRepository.save(grade));
    }

    @Transactional
    public void delete(Long id) {
        Grade grade = findById(id);
        grade.setActive(false);
        gradeRepository.save(grade);
    }

    private Grade findById(Long id) {
        return gradeRepository.findById(id)
                .orElseThrow(() -> new AppException("Note non trouvée", HttpStatus.NOT_FOUND));
    }

    private GradeResponse toResponse(Grade g) {
        double noteSur20 = round((g.getNote() / g.getBareme()) * 20.0);
        return new GradeResponse(
                g.getId(),
                g.getStudent().getId(),
                g.getStudent().getFirstName() + " " + g.getStudent().getLastName(),
                g.getSubject().getId(),
                g.getSubject().getNom(),
                g.getSubject().getCode(),
                g.getTeacher().getId(),
                g.getTeacher().getFirstName() + " " + g.getTeacher().getLastName(),
                g.getType(),
                g.getNote(),
                g.getBareme(),
                g.getCoefficient(),
                noteSur20,
                g.getAppreciation(),
                g.getDateEvaluation(),
                g.isActive(),
                g.getCreatedAt()
        );
    }

    private double round(double value) {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP).doubleValue();
    }
}

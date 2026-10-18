package com.educonnect.config;

import com.educonnect.entities.*;
import com.educonnect.enums.NiveauScolaire;
import com.educonnect.enums.Role;
import com.educonnect.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final TeacherRepository teacherRepository;
    private final StudentRepository studentRepository;
    private final ParentRepository parentRepository;
    private final ClasseRepository classeRepository;
    private final SubjectRepository subjectRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        if (!userRepository.existsByEmail("admin@educonnect.com")) {
            // 1. Admin User
            User adminUser = User.builder()
                    .firstName("Admin")
                    .lastName("EduConnect")
                    .email("admin@educonnect.com")
                    .password(passwordEncoder.encode("admin123"))
                    .role(Role.ADMIN)
                    .enabled(true)
                    .build();
            userRepository.save(adminUser);

            // 2. Enseignant User & Entity
            User teacherUser = User.builder()
                    .firstName("Jean")
                    .lastName("Dupont")
                    .email("teacher@educonnect.com")
                    .password(passwordEncoder.encode("teacher123"))
                    .role(Role.ENSEIGNANT)
                    .enabled(true)
                    .build();
            userRepository.save(teacherUser);

            Teacher teacher = Teacher.builder()
                    .firstName("Jean")
                    .lastName("Dupont")
                    .specialite("Mathématiques")
                    .telephone("0601020304")
                    .user(teacherUser)
                    .active(true)
                    .build();
            teacherRepository.save(teacher);

            // 3. Classe & Subject
            Classe classe = Classe.builder()
                    .nom("3ème A")
                    .niveau(NiveauScolaire.TROISIEME)
                    .salle("Salle 101")
                    .active(true)
                    .build();
            classeRepository.save(classe);

            Subject subject = Subject.builder()
                    .nom("Mathématiques")
                    .code("MATH3")
                    .coefficient(4.0)
                    .teacher(teacher)
                    .active(true)
                    .build();
            subjectRepository.save(subject);

            // 4. Élève User & Entity
            User studentUser = User.builder()
                    .firstName("Lucas")
                    .lastName("Martin")
                    .email("student@educonnect.com")
                    .password(passwordEncoder.encode("student123"))
                    .role(Role.ELEVE)
                    .enabled(true)
                    .build();
            userRepository.save(studentUser);

            Student student = Student.builder()
                    .firstName("Lucas")
                    .lastName("Martin")
                    .dateOfBirth(LocalDate.of(2010, 5, 15))
                    .niveau(NiveauScolaire.TROISIEME)
                    .matricule("MAT2026001")
                    .classe(classe)
                    .user(studentUser)
                    .active(true)
                    .build();
            studentRepository.save(student);

            // 5. Parent User & Entity
            User parentUser = User.builder()
                    .firstName("Pierre")
                    .lastName("Martin")
                    .email("parent@educonnect.com")
                    .password(passwordEncoder.encode("parent123"))
                    .role(Role.PARENT)
                    .enabled(true)
                    .build();
            userRepository.save(parentUser);

            Parent parent = Parent.builder()
                    .firstName("Pierre")
                    .lastName("Martin")
                    .telephone("0699887766")
                    .email("parent@educonnect.com")
                    .user(parentUser)
                    .children(List.of(student))
                    .active(true)
                    .build();
            parentRepository.save(parent);
        }
    }
}

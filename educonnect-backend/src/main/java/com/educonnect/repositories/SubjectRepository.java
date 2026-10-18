package com.educonnect.repositories;

import com.educonnect.entities.Subject;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SubjectRepository extends JpaRepository<Subject, Long> {
    List<Subject> findByActiveTrue();
    List<Subject> findByTeacherIdAndActiveTrue(Long teacherId);
}

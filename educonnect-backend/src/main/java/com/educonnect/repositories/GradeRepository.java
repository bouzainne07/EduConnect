package com.educonnect.repositories;

import com.educonnect.entities.Grade;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GradeRepository extends JpaRepository<Grade, Long> {
    List<Grade> findByStudentIdAndActiveTrue(Long studentId);

    List<Grade> findByTeacherIdAndActiveTrue(Long teacherId);

    List<Grade> findByStudentIdAndSubjectIdAndActiveTrue(Long studentId, Long subjectId);
}

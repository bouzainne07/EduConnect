package com.educonnect.repositories;

import com.educonnect.entities.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    List<Schedule> findByClasseIdAndActiveTrue(Long classeId);

    List<Schedule> findByTeacherIdAndActiveTrue(Long teacherId);

    @Query("SELECT s FROM Schedule s JOIN s.classe c JOIN c.students std WHERE std.id = :studentId AND s.active = true")
    List<Schedule> findByStudentId(@Param("studentId") Long studentId);
}

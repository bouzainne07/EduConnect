package com.educonnect.repositories;

import com.educonnect.entities.Teacher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TeacherRepository extends JpaRepository<Teacher, Long> {
    Page<Teacher> findByActiveTrue(Pageable pageable);

    Optional<Teacher> findByUserIdAndActiveTrue(Long userId);

    @Query("SELECT t FROM Teacher t WHERE t.active = true AND " +
           "(LOWER(t.firstName) LIKE LOWER(CONCAT('%',:q,'%')) OR " +
           "LOWER(t.lastName) LIKE LOWER(CONCAT('%',:q,'%')) OR " +
           "LOWER(t.specialite) LIKE LOWER(CONCAT('%',:q,'%')))")
    Page<Teacher> search(@Param("q") String q, Pageable pageable);
}

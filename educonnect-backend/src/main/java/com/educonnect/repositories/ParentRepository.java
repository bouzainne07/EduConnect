package com.educonnect.repositories;

import com.educonnect.entities.Parent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ParentRepository extends JpaRepository<Parent, Long> {
    Page<Parent> findByActiveTrue(Pageable pageable);

    Optional<Parent> findByUserIdAndActiveTrue(Long userId);

    @Query("SELECT p FROM Parent p JOIN p.children c WHERE c.id = :studentId")
    List<Parent> findByStudentId(@Param("studentId") Long studentId);
}

package com.educonnect.repositories;

import com.educonnect.entities.Student;
import com.educonnect.enums.NiveauScolaire;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Long> {

    Optional<Student> findByMatricule(String matricule);

    boolean existsByMatricule(String matricule);

    Page<Student> findByActiveTrue(Pageable pageable);

    Page<Student> findByNiveauAndActiveTrue(NiveauScolaire niveau, Pageable pageable);

    Optional<Student> findByUserIdAndActiveTrue(Long userId);

    // Recherche par nom/prénom (insensible à la casse)
    @Query("SELECT s FROM Student s WHERE s.active = true AND " +
           "(LOWER(s.firstName) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(s.lastName) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(s.matricule) LIKE LOWER(CONCAT('%', :query, '%')))")
    Page<Student> searchStudents(@Param("query") String query, Pageable pageable);
}

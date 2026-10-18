package com.educonnect.repositories;

import com.educonnect.entities.Classe;
import com.educonnect.enums.NiveauScolaire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClasseRepository extends JpaRepository<Classe, Long> {
    List<Classe> findByActiveTrue();
    List<Classe> findByNiveauAndActiveTrue(NiveauScolaire niveau);
    Optional<Classe> findByNomAndActiveTrue(String nom);
    boolean existsByNom(String nom);
}

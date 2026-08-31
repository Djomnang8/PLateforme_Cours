package com.example.gestion_formation.repository;

import com.example.gestion_formation.entity.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface QuizRepository extends JpaRepository<Quiz, Long> {

    /**
     * Le quiz rattache a un cours.
     *
     * Cette methode etait appelee par ProgressController mais n'existait pas :
     * le module ne compilait pas. Un cours porte au plus un quiz, d'ou
     * l'Optional plutot qu'une liste.
     */
    Optional<Quiz> findByCourseId(Long courseId);
}

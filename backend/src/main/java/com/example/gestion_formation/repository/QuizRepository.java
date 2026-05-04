package com.example.gestion_formation.repository;

import com.example.gestion_formation.entity.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuizRepository extends JpaRepository<Quiz, Long> {}

package com.example.gestion_formation.repository;

import com.example.gestion_formation.entity.Progress;
import com.example.gestion_formation.entity.AppUser;
import com.example.gestion_formation.entity.Course;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface ProgressRepository extends JpaRepository<Progress, Long> {
    Optional<Progress> findByLearnerAndCourse(AppUser learner, Course course);
}
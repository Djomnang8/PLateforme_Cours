package com.example.gestion_formation.repository;

import com.example.gestion_formation.entity.Course;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CourseRepository extends JpaRepository<Course, Long> {}

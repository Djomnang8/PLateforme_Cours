package com.example.gestion_formation.controller;

import com.example.gestion_formation.repository.*;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AnalyticsController {
    private final CourseRepository courseRepository;
    private final QuizRepository quizRepository;
    private final ProgressRepository progressRepository;
    private final CertificationRepository certificationRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public Map<String, Long> stats() {
        return Map.of(
                "totalCourses", courseRepository.count(),
                "totalQuizzes", quizRepository.count(),
                "totalProgress", progressRepository.count(),
                "totalCertifications", certificationRepository.count());
    }
}

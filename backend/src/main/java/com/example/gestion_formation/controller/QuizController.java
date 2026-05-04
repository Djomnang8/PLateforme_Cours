package com.example.gestion_formation.controller;

import com.example.gestion_formation.dto.QuizRequest;
import com.example.gestion_formation.entity.Quiz;
import com.example.gestion_formation.repository.CourseRepository;
import com.example.gestion_formation.repository.QuizRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/quizzes")
@RequiredArgsConstructor
public class QuizController {
    private final QuizRepository repository;
    private final CourseRepository courseRepository;

    @GetMapping
    public List<Quiz> all() {
        return repository.findAll();
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public Quiz create(@RequestBody QuizRequest req) {
        Quiz q = Quiz.builder()
                .title(req.title())
                .passingScore(req.passingScore())
                .course(courseRepository.findById(req.courseId()).orElseThrow())
                .build();
        return repository.save(q);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public Quiz update(@PathVariable Long id, @RequestBody QuizRequest req) {
        Quiz q = repository.findById(id).orElseThrow();
        q.setTitle(req.title());
        q.setPassingScore(req.passingScore());
        q.setCourse(courseRepository.findById(req.courseId()).orElseThrow());
        return repository.save(q);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public void delete(@PathVariable Long id) {
        repository.deleteById(id);
    }
}
package com.example.gestion_formation.controller;

import com.example.gestion_formation.entity.AppUser;
import com.example.gestion_formation.entity.Course;
import com.example.gestion_formation.entity.Progress;
import com.example.gestion_formation.repository.AppUserRepository;
import com.example.gestion_formation.repository.CourseRepository;
import com.example.gestion_formation.repository.ProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/progress")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")  // peut être retiré si CORS global est en place
public class ProgressController {
    private final ProgressRepository repository;
    private final AppUserRepository userRepository;
    private final CourseRepository courseRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')")
    public List<Progress> all() {
        return repository.findAll();
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')")
    public Progress create(@RequestBody Progress p) {
        return repository.save(p);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')")
    public Progress update(@PathVariable Long id, @RequestBody Progress p) {
        p.setId(id);
        return repository.save(p);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('LEARNER','ADMIN')")
    public void delete(@PathVariable Long id) {
        repository.deleteById(id);
    }

    // Progression de l'apprenant connecté
    @GetMapping("/my")
    @PreAuthorize("hasRole('LEARNER')")
    public List<Progress> myProgress(Authentication auth) {
        AppUser user = userRepository.findByEmail(auth.getName()).orElseThrow();
        return repository.findAll().stream()
                .filter(p -> p.getLearner().getId().equals(user.getId()))
                .toList();
    }

    // Mettre à jour la progression pour un cours donné
    @PutMapping("/my/{courseId}")
    @PreAuthorize("hasRole('LEARNER')")
    public ResponseEntity<?> updateMyProgress(@PathVariable Long courseId,
                                              @RequestBody Map<String, Integer> body,
                                              Authentication auth) {
        AppUser user = userRepository.findByEmail(auth.getName()).orElseThrow();
        Course course = courseRepository.findById(courseId).orElseThrow();
        int percent = body.getOrDefault("completionPercent", 0);
        Progress progress = repository.findByLearnerAndCourse(user, course)
                .orElse(Progress.builder().learner(user).course(course).completionPercent(0).build());
        progress.setCompletionPercent(percent);
        repository.save(progress);
        return ResponseEntity.ok().build();
    }
}

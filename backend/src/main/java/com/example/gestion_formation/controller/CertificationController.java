package com.example.gestion_formation.controller;

import com.example.gestion_formation.dto.CertificationRequest;
import com.example.gestion_formation.entity.Certification;
import com.example.gestion_formation.repository.AppUserRepository;
import com.example.gestion_formation.repository.CertificationRepository;
import com.example.gestion_formation.repository.CourseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/certifications")
@RequiredArgsConstructor
public class CertificationController {
    private final CertificationRepository repository;
    private final AppUserRepository userRepository;
    private final CourseRepository courseRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')")
    public List<Certification> all() {
        return repository.findAll();
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public Certification create(@RequestBody CertificationRequest req) {
        Certification c = Certification.builder()
                .learner(userRepository.findById(req.learnerId()).orElseThrow())
                .course(courseRepository.findById(req.courseId()).orElseThrow())
                .issuedAt(req.issuedAt())
                .build();
        return repository.save(c);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public Certification update(@PathVariable Long id, @RequestBody CertificationRequest req) {
        Certification c = repository.findById(id).orElseThrow();
        c.setLearner(userRepository.findById(req.learnerId()).orElseThrow());
        c.setCourse(courseRepository.findById(req.courseId()).orElseThrow());
        c.setIssuedAt(req.issuedAt());
        return repository.save(c);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void delete(@PathVariable Long id) {
        repository.deleteById(id);
    }
}

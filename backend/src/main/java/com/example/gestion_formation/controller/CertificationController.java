package com.example.gestion_formation.controller;

import com.example.gestion_formation.entity.Certification;
import com.example.gestion_formation.repository.CertificationRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/certifications")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CertificationController {
    private final CertificationRepository repository;

    @GetMapping @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')") public List<Certification> all(){ return repository.findAll(); }
    @PostMapping @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')") public Certification create(@RequestBody Certification c){ return repository.save(c);} 
    @PutMapping("/{id}") @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')") public Certification update(@PathVariable Long id, @RequestBody Certification c){ c.setId(id); return repository.save(c);} 
    @DeleteMapping("/{id}") @PreAuthorize("hasRole('ADMIN')") public void delete(@PathVariable Long id){ repository.deleteById(id);} 
}

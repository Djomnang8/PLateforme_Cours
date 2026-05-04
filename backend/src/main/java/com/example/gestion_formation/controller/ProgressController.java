package com.example.gestion_formation.controller;

import com.example.gestion_formation.entity.Progress;
import com.example.gestion_formation.repository.ProgressRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/progress")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProgressController {
    private final ProgressRepository repository;

    @GetMapping @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')") public List<Progress> all(){ return repository.findAll(); }
    @PostMapping @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')") public Progress create(@RequestBody Progress p){ return repository.save(p);} 
    @PutMapping("/{id}") @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')") public Progress update(@PathVariable Long id, @RequestBody Progress p){ p.setId(id); return repository.save(p);} 
    @DeleteMapping("/{id}") @PreAuthorize("hasAnyRole('LEARNER','ADMIN')") public void delete(@PathVariable Long id){ repository.deleteById(id);} 
}

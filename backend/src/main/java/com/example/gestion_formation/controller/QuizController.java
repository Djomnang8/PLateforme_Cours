package com.example.gestion_formation.controller;

import com.example.gestion_formation.entity.Quiz;
import com.example.gestion_formation.repository.QuizRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/quizzes")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class QuizController {
    private final QuizRepository repository;
    @GetMapping public List<Quiz> all(){ return repository.findAll(); }
    @PostMapping @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')") public Quiz create(@RequestBody Quiz q){ return repository.save(q);} 
    @PutMapping("/{id}") @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')") public Quiz update(@PathVariable Long id,@RequestBody Quiz q){ q.setId(id); return repository.save(q);} 
    @DeleteMapping("/{id}") @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')") public void delete(@PathVariable Long id){ repository.deleteById(id);} 
}

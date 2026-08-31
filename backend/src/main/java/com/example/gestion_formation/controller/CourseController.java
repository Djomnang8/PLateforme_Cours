package com.example.gestion_formation.controller;

import com.example.gestion_formation.entity.Course;
import com.example.gestion_formation.repository.CourseRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/courses")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CourseController {
    private final CourseRepository repository;

   @GetMapping
public List<Course> all(@RequestParam(required = false) String search) {
    if (search != null && !search.isEmpty()) {
        return repository.findByTitleContainingIgnoreCase(search);
    }
    return repository.findAll();
}
    @PostMapping @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')") public Course create(@RequestBody Course c) { return repository.save(c); }
    @PutMapping("/{id}") @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')") public Course update(@PathVariable Long id, @RequestBody Course c){ c.setId(id); return repository.save(c);} 
    @DeleteMapping("/{id}") @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')") public void delete(@PathVariable Long id){ repository.deleteById(id);} 
    

}

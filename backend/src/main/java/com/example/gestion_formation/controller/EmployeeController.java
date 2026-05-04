package com.example.gestion_formation.controller;

import com.example.gestion_formation.entity.AppUser;
import com.example.gestion_formation.entity.Role;
import com.example.gestion_formation.repository.AppUserRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/employees")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class EmployeeController {
    private final AppUserRepository repository;
    private final PasswordEncoder encoder;

    @GetMapping public List<AppUser> all(){ return repository.findAll().stream().filter(u -> u.getRole()!=Role.ROLE_LEARNER).toList(); }
    @PostMapping public AppUser create(@RequestBody AppUser u){ u.setId(null); u.setPassword(u.getPassword()); return repository.save(u);} 
    @PutMapping("/{id}") public AppUser update(@PathVariable Long id,@RequestBody AppUser u){ u.setId(id); u.setPassword(u.getPassword()); return repository.save(u);} 
    @DeleteMapping("/{id}") public void delete(@PathVariable Long id){ repository.deleteById(id);} 
}

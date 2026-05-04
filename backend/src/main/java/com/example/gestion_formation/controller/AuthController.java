package com.example.gestion_formation.controller;

import com.example.gestion_formation.dto.*;
import com.example.gestion_formation.entity.AppUser;
import com.example.gestion_formation.entity.Role;
import com.example.gestion_formation.repository.AppUserRepository;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {
    private final AppUserRepository userRepository;
    private final PasswordEncoder encoder;


    @PostMapping("/register")
    public ResponseEntity<?> registerLearner(@RequestBody RegisterLearnerRequest req) {
        if (userRepository.findByEmail(req.email()).isPresent()) return ResponseEntity.badRequest().body(Map.of("error", "Email déjà utilisé"));
        AppUser user = AppUser.builder()
                .fullName(req.fullName())
                .email(req.email())
                .password(req.password())
                .matricule("CLT" + System.currentTimeMillis())
                .role(Role.ROLE_LEARNER)
                .build();
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("message", "Inscription réussie"));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req) {
        AppUser user = userRepository.findByEmail(req.email()).orElseThrow();
        if (!req.password().equals(user.getPassword())) return ResponseEntity.status(401).body(Map.of("error", "Identifiants invalides"));
        boolean requiresSecondFactor = user.getRole().name().contains("EMPLOYEE") || user.getRole().name().contains("ADMIN");
        return ResponseEntity.ok(Map.of("email", user.getEmail(), "role", user.getRole(), "requiresSecondFactor", requiresSecondFactor));
    }

    @PostMapping("/verify-matricule")
    public ResponseEntity<?> verifyMatricule(@RequestBody SecondFactorRequest req) {
        AppUser user = userRepository.findByEmail(req.email()).orElseThrow();
        if (!user.getMatricule().equals(req.matricule())) return ResponseEntity.status(401).body(Map.of("error", "Matricule invalide"));
        return ResponseEntity.ok(Map.of("message", "2FA validé"));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest req) {
        AppUser user = userRepository.findByEmail(req.email()).orElseThrow();
        user.setPassword(req.newPassword());
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("message", "Mot de passe réinitialisé"));
    }
}
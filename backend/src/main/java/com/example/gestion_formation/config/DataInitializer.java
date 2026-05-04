package com.example.gestion_formation.config;

import com.example.gestion_formation.entity.*;
import com.example.gestion_formation.repository.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
@RequiredArgsConstructor
public class DataInitializer {
    @Bean
    CommandLineRunner init(AppUserRepository repo, PasswordEncoder encoder) {
        return args -> {
            if (repo.count() == 0) {
                repo.save(AppUser.builder().fullName("Admin Principal").email("admin@formation.local").password(encoder.encode("Admin@123")).matricule("ADM001").role(Role.ROLE_ADMIN).build());
                repo.save(AppUser.builder().fullName("Employe RH").email("employe@formation.local").password(encoder.encode("Employe@123")).matricule("EMP001").role(Role.ROLE_EMPLOYEE).build());
                repo.save(AppUser.builder().fullName("Client Demo").email("client@formation.local").password(encoder.encode("Client@123")).matricule("CLT001").role(Role.ROLE_LEARNER).build());
            }
        };
    }
}

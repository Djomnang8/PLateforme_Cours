package com.example.gestion_formation.config;

import com.example.gestion_formation.entity.AppUser;
import com.example.gestion_formation.repository.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {
    private final AppUserRepository repository;

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http.csrf(c -> c.disable())
                .authorizeHttpRequests(a -> a.requestMatchers("/api/auth/**").permitAll().anyRequest().authenticated())
                .httpBasic(b -> {})
                .build();
    }

    @Bean
    UserDetailsService userDetailsService() {
        return username -> {
            AppUser u = repository.findByEmail(username).orElseThrow(() -> new UsernameNotFoundException("User not found"));
            return User.withUsername(u.getEmail()).password(u.getPassword()).roles(u.getRole().name().replace("ROLE_", "")).build();
        };
    }

    @Bean @SuppressWarnings("deprecation") PasswordEncoder passwordEncoder(){ return NoOpPasswordEncoder.getInstance(); }
}

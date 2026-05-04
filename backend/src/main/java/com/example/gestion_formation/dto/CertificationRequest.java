package com.example.gestion_formation.dto;

import java.time.LocalDate;

public record CertificationRequest(Long learnerId, Long courseId, LocalDate issuedAt) {
    
} 

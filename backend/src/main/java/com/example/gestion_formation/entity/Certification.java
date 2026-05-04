package com.example.gestion_formation.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import lombok.*;

@Entity
@Table(name = "certifications")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Certification {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(optional = false)
    private AppUser learner;
    @ManyToOne(optional = false)
    private Course course;
    @Column(nullable = false)
    private LocalDate issuedAt;
}

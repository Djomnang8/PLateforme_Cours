package com.example.gestion_formation.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "progress")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Progress {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(optional = false)
    private AppUser learner;
    @ManyToOne(optional = false)
    private Course course;
    @Column(nullable = false)
    private Integer completionPercent;
}

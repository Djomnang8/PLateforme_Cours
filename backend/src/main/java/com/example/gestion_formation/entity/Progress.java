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

    @Builder.Default
    private Integer documentProgress = 0;   // 0-50

    @Builder.Default
    private Integer quizProgress = 0;       // 0-50

    /**
     * Progression totale : lecture du document (0-50) + reussite du quiz (0-50).
     *
     * Les deux moities sont lues avec une valeur de repli. Les lignes creees
     * avant que la progression soit scindee en deux ont ces colonnes a NULL :
     * l'addition levait alors une NullPointerException au moment de serialiser
     * la reponse, et la route /api/progress repondait 500 pour tout le monde a
     * cause d'une seule ligne heritee.
     *
     * Une valeur calculee ne doit pas pouvoir faire tomber une lecture.
     */
    public Integer getCompletionPercent() {
        int doc = documentProgress == null ? 0 : documentProgress;
        int quiz = quizProgress == null ? 0 : quizProgress;
        return Math.min(100, doc + quiz);
    }
}
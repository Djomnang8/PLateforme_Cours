package com.example.gestion_formation.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "courses")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Course {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false)
    private String title;
    @Column(nullable = false, length = 2000)
    private String description;
    @Column(nullable = false)
    private boolean active;

    /**
     * Collection ignoree a la serialisation.
     *
     * Avec spring.jpa.open-in-view=false — le bon reglage — la session
     * Hibernate est fermee quand Jackson serialise la reponse. Toute
     * collection chargee paresseusement leve alors une
     * LazyInitializationException, transformee en erreur 500 : les routes
     * /api/courses, /api/progress et /api/certifications repondaient toutes
     * les trois 500, c'est-a-dire l'essentiel de l'application.
     *
     * Les documents d'un cours ont deja leur propre route,
     * /api/courses/{{courseId}}/documents : les inclure dans chaque cours de la
     * liste n'apporterait rien et alourdirait la reponse.
     */
    @com.fasterxml.jackson.annotation.JsonIgnore
    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL, orphanRemoval = true)
@Builder.Default
    private List<Document> documents = new ArrayList<>();
}

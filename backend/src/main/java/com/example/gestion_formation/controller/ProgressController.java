package com.example.gestion_formation.controller;

import com.example.gestion_formation.entity.AppUser;
import com.example.gestion_formation.entity.Course;
import com.example.gestion_formation.entity.Progress;
import com.example.gestion_formation.repository.AppUserRepository;
import com.example.gestion_formation.repository.CourseRepository;
import com.example.gestion_formation.repository.ProgressRepository;
import com.example.gestion_formation.repository.QuestionRepository;
import com.example.gestion_formation.repository.QuizRepository;
import com.example.gestion_formation.entity.Question;
import com.example.gestion_formation.entity.Quiz;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/progress")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")  // peut être retiré si CORS global est en place
public class ProgressController {
    private final ProgressRepository repository;
    private final AppUserRepository userRepository;
    private final CourseRepository courseRepository;
    // Ces deux depots etaient importes et utilises, mais jamais declares comme
    // champs : le module ne compilait pas.
    private final QuizRepository quizRepository;
    private final QuestionRepository questionRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')")
    public List<Progress> all() {
        return repository.findAll();
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')")
    public Progress create(@RequestBody Progress p) {
        return repository.save(p);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')")
    public Progress update(@PathVariable Long id, @RequestBody Progress p) {
        p.setId(id);
        return repository.save(p);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('LEARNER','ADMIN')")
    public void delete(@PathVariable Long id) {
        repository.deleteById(id);
    }

    // Progression de l'apprenant connecté
    @GetMapping("/my")
    @PreAuthorize("hasRole('LEARNER')")
    public List<Progress> myProgress(Authentication auth) {
        AppUser user = userRepository.findByEmail(auth.getName()).orElseThrow();
        return repository.findAll().stream()
                .filter(p -> p.getLearner().getId().equals(user.getId()))
                .toList();
    }

    // Mettre à jour la progression pour un cours donné
    @PutMapping("/my/{courseId}")
    @PreAuthorize("hasRole('LEARNER')")
    public ResponseEntity<?> updateMyProgress(@PathVariable Long courseId,
                                              @RequestBody Map<String, Integer> body,
                                              Authentication auth) {
        AppUser user = userRepository.findByEmail(auth.getName()).orElseThrow();
        Course course = courseRepository.findById(courseId).orElseThrow();

        // La progression a ete scindee en deux moities — lecture du document
        // (0-50) et reussite du quiz (0-50) — mais ce point d'entree parlait
        // encore d'un « completionPercent » unique qui n'existe plus dans
        // l'entite. Il ne compilait donc pas.
        //
        // Le pourcentage recu est interprete comme la progression de lecture,
        // seule moitie qu'un client peut legitimement declarer : la moitie quiz
        // ne s'obtient qu'en repondant au quiz, jamais en l'annoncant.
        int percent = Math.min(50, Math.max(0, body.getOrDefault("completionPercent", 0)));
        Progress progress = repository.findByLearnerAndCourse(user, course)
                .orElse(Progress.builder().learner(user).course(course).build());
        progress.setDocumentProgress(percent);
        repository.save(progress);
        return ResponseEntity.ok().build();
    }



    @PutMapping("/my/{courseId}/scroll")
@PreAuthorize("hasRole('LEARNER')")
public ResponseEntity<?> updateScrollProgress(@PathVariable Long courseId,
                                              @RequestBody Map<String, Integer> body,
                                              Authentication auth) {
    AppUser user = userRepository.findByEmail(auth.getName()).orElseThrow();
    int percent = body.getOrDefault("percent", 0);
    percent = Math.min(50, Math.max(0, percent)); // limité à 50
    Progress progress = repository.findByLearnerAndCourse(user, courseRepository.findById(courseId).orElseThrow())
            .orElse(Progress.builder().learner(user).course(courseRepository.findById(courseId).orElseThrow()).build());
    progress.setDocumentProgress(percent);
    repository.save(progress);
    return ResponseEntity.ok().build();
}

@PostMapping("/my/{courseId}/submit-quiz")
@PreAuthorize("hasRole('LEARNER')")
public ResponseEntity<?> submitQuiz(@PathVariable Long courseId,
                                    @RequestBody List<Integer> answers,   // liste des réponses (index)
                                    Authentication auth) {
    AppUser user = userRepository.findByEmail(auth.getName()).orElseThrow();
    Course course = courseRepository.findById(courseId).orElseThrow();
    Quiz quiz = quizRepository.findByCourseId(courseId).orElseThrow();
    List<Question> questions = questionRepository.findByQuizId(quiz.getId());
    int correct = 0;
    for (int i = 0; i < questions.size(); i++) {
        if (i < answers.size() && answers.get(i) == questions.get(i).getCorrectIndex()) {
            correct++;
        }
    }
    // Un quiz sans question donnerait une division par zero : le calcul
    // planterait en 500 au lieu de refuser proprement la soumission.
    if (questions.isEmpty()) {
        return ResponseEntity.badRequest()
                .body(Map.of("erreur", "Ce quiz ne contient aucune question."));
    }
    int score = (int) ((correct * 100.0) / questions.size());
    int quizProgress = score >= quiz.getPassingScore() ? 50 : 0;   // tout ou rien
    Progress progress = repository.findByLearnerAndCourse(user, course)
            .orElse(Progress.builder().learner(user).course(course).build());
    progress.setQuizProgress(quizProgress);
    repository.save(progress);
    return ResponseEntity.ok(Map.of("score", score, "passed", quizProgress == 50));
}
}

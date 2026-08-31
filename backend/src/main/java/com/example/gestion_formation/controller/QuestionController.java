package com.example.gestion_formation.controller;

import com.example.gestion_formation.entity.Question;
import com.example.gestion_formation.entity.Quiz;
import com.example.gestion_formation.repository.QuestionRepository;
import com.example.gestion_formation.repository.QuizRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/quizzes/{quizId}/questions")
@RequiredArgsConstructor
public class QuestionController {
    private final QuestionRepository questionRepository;
    private final QuizRepository quizRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')")
    public List<Question> list(@PathVariable Long quizId) {
        return questionRepository.findByQuizId(quizId);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public Question create(@PathVariable Long quizId, @RequestBody Question q) {
        Quiz quiz = quizRepository.findById(quizId).orElseThrow();
        q.setQuiz(quiz);
        return questionRepository.save(q);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public Question update(@PathVariable Long quizId, @PathVariable Long id, @RequestBody Question q) {
        Question existing = questionRepository.findById(id).orElseThrow();
        existing.setText(q.getText());
        existing.setOptions(q.getOptions());
        existing.setCorrectIndex(q.getCorrectIndex());
        return questionRepository.save(existing);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public void delete(@PathVariable Long quizId, @PathVariable Long id) {
        questionRepository.deleteById(id);
    }
}
package com.example.gestion_formation.dto;

public record QuizRequest(String title, int passingScore, Long courseId) {}
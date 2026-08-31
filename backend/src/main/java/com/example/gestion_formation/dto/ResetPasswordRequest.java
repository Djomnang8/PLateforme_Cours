package com.example.gestion_formation.dto;

/**
 * Le matricule a ete ajoute a la demande de reinitialisation.
 *
 * Sans lui, la seule adresse e-mail suffisait a changer le mot de passe de
 * n'importe quel compte, administrateur compris. Voir AuthController pour le
 * detail et pour la correction definitive envisagee (jeton envoye par courriel).
 */
public record ResetPasswordRequest(String email, String matricule, String newPassword) {}

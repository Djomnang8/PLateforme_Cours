package com.example.gestion_formation.controller;

import com.example.gestion_formation.dto.*;
import com.example.gestion_formation.entity.AppUser;
import com.example.gestion_formation.entity.Role;
import com.example.gestion_formation.repository.AppUserRepository;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {
    private final AppUserRepository userRepository;
    private final PasswordEncoder encoder;

    /**
     * Compare un mot de passe saisi a ce qui est stocke, en migrant au passage
     * les empreintes heritees.
     *
     * La base contient encore des mots de passe ecrits en clair, produits par
     * la version precedente. Les effacer priverait les utilisateurs de leur
     * compte ; les laisser en clair maintiendrait la faille. La premiere
     * connexion reussie d'un compte non migre reecrit donc son mot de passe
     * sous forme d'empreinte BCrypt, et le compte est protege a partir de la.
     *
     * Une empreinte BCrypt commence toujours par $2a$, $2b$ ou $2y$ : c'est ce
     * qui permet de distinguer un enregistrement deja migre.
     */
    private boolean motDePasseValide(AppUser user, String saisi) {
        String stocke = user.getPassword();
        if (stocke == null || saisi == null) return false;

        if (stocke.startsWith("$2a$") || stocke.startsWith("$2b$") || stocke.startsWith("$2y$")) {
            return encoder.matches(saisi, stocke);
        }

        if (!stocke.equals(saisi)) return false;
        user.setPassword(encoder.encode(saisi));
        userRepository.save(user);
        return true;
    }


    @PostMapping("/register")
    public ResponseEntity<?> registerLearner(@RequestBody RegisterLearnerRequest req) {
        if (userRepository.findByEmail(req.email()).isPresent()) return ResponseEntity.badRequest().body(Map.of("error", "Email déjà utilisé"));
        AppUser user = AppUser.builder()
                .fullName(req.fullName())
                .email(req.email())
                .password(encoder.encode(req.password()))
                .matricule("CLT" + System.currentTimeMillis())
                .role(Role.ROLE_LEARNER)
                .build();
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("message", "Inscription réussie"));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req) {
        // orElseThrow() renvoyait une erreur 500 quand l'adresse n'existait pas,
        // la ou un mot de passe errone renvoyait 401. La difference suffisait a
        // savoir quelles adresses possedent un compte : on repond desormais la
        // meme chose dans les deux cas.
        AppUser user = userRepository.findByEmail(req.email()).orElse(null);
        if (user == null || !motDePasseValide(user, req.password())) {
            return ResponseEntity.status(401).body(Map.of("error", "Identifiants invalides"));
        }
        boolean requiresSecondFactor = user.getRole().name().contains("EMPLOYEE") || user.getRole().name().contains("ADMIN");
        return ResponseEntity.ok(Map.of("email", user.getEmail(), "role", user.getRole(), "requiresSecondFactor", requiresSecondFactor));
    }

    @PostMapping("/verify-matricule")
    public ResponseEntity<?> verifyMatricule(@RequestBody SecondFactorRequest req) {
        AppUser user = userRepository.findByEmail(req.email()).orElseThrow();
        if (!user.getMatricule().equals(req.matricule())) return ResponseEntity.status(401).body(Map.of("error", "Matricule invalide"));
        return ResponseEntity.ok(Map.of("message", "2FA validé"));
    }

    /**
     * Reinitialisation du mot de passe.
     *
     * La version precedente changeait le mot de passe de n'importe quel compte
     * a partir de la seule adresse e-mail, sans aucune preuve. Connaitre
     * l'adresse d'un collegue suffisait a prendre son compte, y compris un
     * compte administrateur. La route etait de surcroit ouverte a tous, comme
     * tout /api/auth/**.
     *
     * Le matricule est desormais exige : c'est le second facteur deja utilise
     * a la connexion des employes et des administrateurs. Ce n'est pas un
     * secret solide — il figure dans les listes du personnel — mais il ferme la
     * prise de controle a partir de la seule adresse.
     *
     * La vraie correction est un jeton a usage unique envoye par courriel, avec
     * une duree de validite courte. Elle demande un service d'envoi, absent du
     * projet : c'est note dans le README comme le prochain chantier.
     */
    @PostMapping("/forgot-password")
    public ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest req) {
        AppUser user = userRepository.findByEmail(req.email()).orElse(null);
        if (user == null || req.matricule() == null
                || !user.getMatricule().equals(req.matricule())) {
            // Meme reponse que le compte existe ou non : sinon la route devient
            // un moyen de tester quelles adresses sont enregistrees.
            return ResponseEntity.status(401).body(Map.of("error", "Adresse ou matricule incorrect"));
        }
        user.setPassword(encoder.encode(req.newPassword()));
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("message", "Mot de passe réinitialisé"));
    }
}
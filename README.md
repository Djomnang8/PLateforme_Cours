# Plateforme de formation interne — Spring Boot + Flutter

Application de formation interne : catalogue de cours, documents, quiz notés,
progression des apprenants et délivrance de certifications. Trois rôles —
administrateur, employé, apprenant.

**Stack** : Java 21 · Spring Boot · Spring Security · JPA / Hibernate ·
MySQL (XAMPP) · Flutter

> **État du dépôt.** Le backend ne compilait pas, et trois faiblesses de
> sécurité ont été corrigées. **Le frontend Flutter ne compile toujours pas** :
> les sept erreurs restantes sont listées plus bas, elles ne sont pas masquées.

---

## L'API, vérifiée de bout en bout

![Sortie du script verifier-api.sh : connexion réussie avec le rôle ROLE_ADMIN et second facteur exigé, puis cinq routes interrogées avec succès — courses 2 enregistrements, employees 2, progress 3, certifications 3, analytics 0 — suivies du catalogue des formations et de la progression enregistrée par apprenant](docs/01-api-verifiee.png)

**Ce que montre cette image.** Le backend interrogé avec un vrai compte, contre
la base MySQL. Chaque ligne est une route qui répond réellement, et le nombre
d'enregistrements est celui de la base.

La dernière section mérite un mot : la progression d'un apprenant s'affiche
comme **lecture 0/50 + quiz 0/50**. Ce n'est pas cosmétique, c'est la règle
métier centrale. Lire le document ne peut jamais donner plus de la moitié de la
progression ; l'autre moitié s'obtient uniquement en réussissant le quiz, et
elle est attribuée en tout ou rien. Un apprenant qui fait défiler la page
jusqu'en bas sans rien comprendre plafonne à 50 %.

---

## Sécurité : ce qui a changé

![Sortie du script verifier-securite.sh : six vérifications toutes en OK — connexion valide en 200, mot de passe erroné en 401, adresse inconnue en 401 identique, réinitialisation sans matricule refusée en 401, mot de passe inchangé après la tentative, et empreinte BCrypt de 60 caractères lue en base](docs/02-securite-verifiee.png)

**Ce que montre cette image.** Les trois points, verrouillés par un script qui
échoue si l'un d'eux revient. La dernière ligne lit directement la colonne
`password` en base : elle contenait `admin123` en clair, elle contient
maintenant une empreinte BCrypt de 60 caractères.

### 1. Les mots de passe étaient stockés en clair

C'était **assumé** : la dernière ligne du README d'origine le disait
explicitement, comme un choix de l'exercice. Le bean `PasswordEncoder` existait
d'ailleurs et était injecté, mais renvoyait `NoOpPasswordEncoder` — l'encodeur
que Spring fournit pour ne rien encoder, et qu'il marque déprécié pour cette
raison.

Défendable dans un devoir, indéfendable dans un dépôt public : n'importe quel
lecteur y voit une application qui stocke des mots de passe en clair, et la
base de démonstration en contient de vrais.

`BCryptPasswordEncoder` est donc utilisé. Les comptes existants ne sont pas
effacés : la première connexion réussie d'un compte encore en clair réécrit son
mot de passe sous forme d'empreinte. **Migration transparente, aucun compte
perdu, aucune intervention manuelle.**

### 2. N'importe qui pouvait prendre n'importe quel compte

`POST /api/auth/forgot-password` changeait le mot de passe à partir de la seule
adresse e-mail, sans aucune preuve, sur une route ouverte à tous
(`/api/auth/**` est en `permitAll`). Connaître l'adresse d'un collègue suffisait
à prendre son compte — **y compris un compte administrateur.** Celui-là n'était
écrit nulle part comme un choix.

Le matricule est maintenant exigé. Ce n'est pas un secret solide, il figure dans
les listes du personnel, mais il ferme la prise de contrôle à partir de la seule
adresse. La correction définitive — un jeton à usage unique envoyé par courriel,
à durée de validité courte — demande un service d'envoi, absent du projet.

### 3. On pouvait deviner quelles adresses ont un compte

`findByEmail(...).orElseThrow()` faisait répondre **500** pour une adresse
inconnue, là où un mot de passe erroné répondait **401**. La différence suffit à
parcourir une liste d'adresses et à savoir lesquelles sont enregistrées. Les
deux cas renvoient désormais la même réponse.

---

## Le backend ne compilait pas

Le dépôt était publié dans un état où `mvn package` échoue. Quatre causes
distinctes :

| Fichier | Problème |
|---|---|
| `entity/Quiz.java`, `entity/Course.java` | `List` et `ArrayList` utilisés sans être importés |
| `repository/QuizRepository.java` | `findByCourseId` appelée par le contrôleur, jamais déclarée |
| `controller/ProgressController.java` | `quizRepository` et `questionRepository` utilisés, jamais déclarés comme champs |
| `controller/ProgressController.java` | `completionPercent` écrit et lu alors que l'entité a été scindée en `documentProgress` + `quizProgress` |

Le dernier point est le plus parlant : la progression a été refondue en deux
moitiés, et le contrôleur n'a jamais suivi. Il appelait un constructeur et un
mutateur qui n'existaient plus.

### Deux erreurs 500 découvertes en exécutant

Réparer la compilation ne suffisait pas — trois routes sur cinq répondaient
encore 500 :

- **`Course.documents` et `Quiz.questions`** sont chargées paresseusement. Avec
  `spring.jpa.open-in-view=false` — le bon réglage — la session Hibernate est
  fermée quand Jackson sérialise la réponse, d'où une
  `LazyInitializationException` sur `/api/courses`, `/api/progress` et
  `/api/certifications` : l'essentiel de l'application. Les collections sont
  désormais ignorées à la sérialisation, les documents d'un cours ayant déjà
  leur propre route.
- **`getCompletionPercent()`** additionnait deux `Integer` sans vérifier leur
  nullité. Les lignes créées avant la refonte ont ces colonnes à `NULL` : **une
  seule ligne héritée faisait répondre 500 à toute la route**, pour tout le
  monde. Une valeur calculée ne doit pas pouvoir faire tomber une lecture.

Au passage, `@Builder.Default` manquait sur deux listes. Lombok ignore
l'initialisation d'un champ dans un `@Builder` — il le signale par un
avertissement que personne n'avait lu — et les collections arrivaient donc à
`null` sur les objets construits par le constructeur fluide.

---

## Ce qui ne fonctionne toujours pas

![Sortie du script etat-frontend.sh : sept erreurs de compilation Flutter — type List<int> assigné à un paramètre Map<String, dynamic>, méthode CourseDetailScreen non définie, paramètre nommé search inexistant, parenthèse attendue, trop d'arguments positionnels — et le verdict que l'interface ne peut pas être construite](docs/03-frontend-ne-compile-pas.png)

**Ce que montre cette image.** L'état réel du frontend Flutter :
`flutter build web` échoue sur **sept erreurs**. Un écran référencé
(`CourseDetailScreen`) n'existe pas, un service passe une liste là où une map
est attendue, un écran appelle un constructeur avec des paramètres qu'il ne
déclare pas.

Ce ne sont pas des oublis d'import : c'est un code partiellement refondu, comme
le backend l'était. La réparation est un chantier à part entière, et elle n'est
pas faite. Le script `outils/etat-frontend.sh` sort en code 1 tant que c'est le
cas — il dira tout seul quand ce ne le sera plus.

---

## Lancer le projet

### Backend

```bash
cd backend
mvn spring-boot:run
```

L'API écoute sur <http://localhost:8082>. Les routes métier sont protégées par
authentification HTTP basique.

### Vérifier

```bash
bash outils/verifier-api.sh
bash outils/verifier-securite.sh
bash outils/etat-frontend.sh
```

Les deux premiers sortent en code 0 quand tout répond ; le troisième sort en
code 1 tant que le frontend ne compile pas. Les trois s'utilisent tels quels
dans une chaîne d'intégration continue.

---

## Annexe — le dossier d'origine

## 1) SQL (XAMPP MySQL 3306)
Le script SQL complet est disponible dans: `backend/src/main/resources/schema.sql`.

```sql
CREATE DATABASE IF NOT EXISTS gestion_cours CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gestion_cours;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  matricule VARCHAR(50) NOT NULL UNIQUE,
  role VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS courses (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  active BIT NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS quizzes (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  passing_score INT NOT NULL,
  course_id BIGINT NOT NULL,
  CONSTRAINT fk_quiz_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS progress (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  learner_id BIGINT NOT NULL,
  course_id BIGINT NOT NULL,
  completion_percent INT NOT NULL,
  CONSTRAINT fk_progress_user FOREIGN KEY (learner_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_progress_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS certifications (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  learner_id BIGINT NOT NULL,
  course_id BIGINT NOT NULL,
  issued_at DATE NOT NULL,
  CONSTRAINT fk_cert_user FOREIGN KEY (learner_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_cert_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);
```

## 2) Commandes backend
```bash
cd backend
mvn spring-boot:run
```

API principale: `http://localhost:8081`

## 3) Commandes frontend Flutter
```bash
cd frontend
flutter pub get
flutter run
```

## 4) Authentification demandée
- Page connexion (`LoginScreen`) + lien inscription client
- Page mot de passe oublié (`ForgotPasswordScreen`)
- Connexion avec 2e facteur matricule pour employé/admin (`SecondFactorScreen`)
- Message succès/erreur affiché sur chaque action utilisateur.
- RBAC:
  - ADMIN: tous les droits + CRUD employés
  - EMPLOYEE: CRUD cours + quiz (pas CRUD employés)
  - LEARNER: consultation et progression

## 5) Git
Le dépôt doit rester avec une seule branche: `main`.


## 6) Notes importantes (Web + IntelliJ)
- Si vous lancez Flutter sur **Chrome (Web)**, l'API utilisée est `http://localhost:8081/api`.
- Si vous lancez Flutter sur **émulateur Android**, l'API utilisée est `http://10.0.2.2:8081/api`.
- Erreur IntelliJ `JDK isn't specified for module 'gestion_formation'`:
  - Ouvrir **File > Project Structure > Project SDK**
  - Sélectionner JDK 21 ou 23
  - Dans **Modules > gestion_formation**, affecter le même SDK.



### Correction immédiate de l'erreur IntelliJ
1. **File > Project Structure > Project**
2. Project SDK: choisir `JDK 21` (ou `JDK 23`)
3. Project language level: `21 - LTS`
4. **File > Project Structure > Modules > gestion_formation > Dependencies**
5. Module SDK: choisir le même JDK
6. Appliquer puis reconstruire le projet.

Alternative terminal (sans IntelliJ):
```bash
cd backend
mvn -v
mvn clean compile
mvn spring-boot:run
```

## 7) Dépannage ERR_CONNECTION_REFUSED
- L'erreur `POST http://localhost:8081/... ERR_CONNECTION_REFUSED` signifie que le backend Spring Boot n'est pas démarré.
- Démarrer le backend avant Flutter:
```bash
cd backend
mvn spring-boot:run
```
- Vérifier dans le navigateur: `http://localhost:8081/api/auth/login` (doit répondre 405/401 mais le serveur doit être joignable).
- ~~Les mots de passe sont enregistrés en clair (non chiffrés) dans la base.~~ **Ce n'est plus le cas** : voir la section « Sécurité » en haut de ce fichier.

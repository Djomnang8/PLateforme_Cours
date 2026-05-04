# Plateforme de formation interne (Spring Boot + Flutter)

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
- Conformément à votre demande actuelle, les mots de passe sont enregistrés en clair (non chiffrés) dans la base.

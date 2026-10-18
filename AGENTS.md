# EduConnect — Règles permanentes du projet

## Contexte
Application de gestion scolaire (mobile + web) pour écoles privées/collèges/lycées.
Rôles : ADMIN, DIRECTEUR, ENSEIGNANT, ELEVE, PARENT, SURVEILLANT.

---

## Stack imposée (ne jamais proposer d'alternative sans demande explicite)

**Frontend mobile :** Flutter + Dart, Material Design 3, Riverpod (state), GoRouter (navigation), Dio (HTTP), Flutter Secure Storage, Firebase Cloud Messaging (push).

**Backend :** Spring Boot 3, Java 21, Spring Security + JWT, Spring Data JPA/Hibernate, Spring Validation, Lombok, MapStruct, Spring Mail, Swagger/OpenAPI, Maven.

**BDD :** PostgreSQL (+ Redis en option pour le cache).

**Stockage fichiers :** AWS S3 ou Cloudinary.

**Notifications :** Firebase Cloud Messaging.

---

## Architecture backend (à respecter STRICTEMENT dans chaque génération)

**Flux :** Controller → Service → Repository → Database

**Packages :**
```
controllers/
services/
repositories/
entities/
dto/
security/
config/
exceptions/
utils/
enums/
```

**Règles :**
- Un Controller ne contient AUCUNE logique métier, il délègue au Service.
- DTO obligatoire en entrée/sortie d'API (jamais exposer une Entity directement).
- Mapping Entity ↔ DTO via MapStruct.
- Validation via `@Valid` + Bean Validation (`@NotNull`, `@Size`, etc.).
- Exceptions métier centralisées via `@ControllerAdvice` dans `exceptions/`.
- Chaque endpoint doit être documenté Swagger (`@Operation`, `@Tag`).

---

## Architecture frontend (Flutter)

```
lib/
├─ core/        (constants, theme, utils, errors)
├─ data/        (models, repositories, services API)
├─ providers/   (Riverpod)
├─ routes/      (GoRouter)
└─ features/
    ├─ auth/
    ├─ students/
    ├─ teachers/
    ├─ parents/
    ├─ classes/
    ├─ grades/
    ├─ attendance/
    ├─ homework/
    ├─ exams/
    ├─ messaging/
    ├─ documents/
    └─ dashboard/
```

Chaque feature suit le pattern : `presentation/` (UI), `application/` (state/providers), `data/` (repository + models).

---

## Design
- Palette : Bleu `#2563EB`, blanc, gris clair, vert (validation), rouge (alerte).
- Material 3, cartes modernes, mode sombre, multilingue (FR/AR/EN).

---

## Règle d'or pour l'agent
- Ne jamais générer plusieurs modules en même temps — un module = une tâche = une conversation courte.
- Toujours commencer un module par : Entity → DTO → Repository → Service → Controller → (puis Flutter).
- Réutiliser les entités/DTO déjà créés au lieu de les recréer.
- Si une info manque (ex: règle métier précise), poser UNE question courte plutôt que de deviner.
- Code commenté uniquement si complexe ; pas de commentaires évidents.

---

## Roadmap en phases

### Phase 0 — Setup
- Backend : Spring Boot 3 / Java 21, structure packages, `application.yml` (dev/prod), connexion PostgreSQL.
- Frontend : Flutter, dépendances, structure `lib/`, thème Material 3, GoRouter squelette + écran login vide.

### Phase 1 — Authentification & Utilisateurs
- Backend : Entity `User`, inscription, login JWT, refresh token, Spring Security + filtre JWT.
- Frontend : Écrans Login, gestion token (Secure Storage), redirection GoRouter par rôle, Riverpod `AuthState`.

### Phase 2 — Entités cœur (une par une)
- Élèves : Entity `Student`, classe, niveau, dossier, parents. CRUD + upload photo.
- Enseignants : Entity `Teacher` (matières, classes, disponibilités). CRUD.
- Parents : Entity `Parent` ↔ `Student` (many-to-many). Endpoints notes/absences/devoirs enfants.
- Classes & Matières : Entities `Classe` + `Subject`. CRUD.

### Phase 3 — Emploi du temps
- Entity `Schedule` (Classe/Subject/Teacher/salle/créneau). Endpoint "mon emploi du temps" par rôle. Vue calendrier Flutter.

### Phase 4 — Notes & Absences
- Notes : Entity `Grade` (CONTROLE/DEVOIR/TP/EXAMEN). Moyennes auto, classement.
- Absences : Entity `Attendance` (présence/absence/retard/justification). Notification push parent.

### Phase 5 — Devoirs & Examens
- Devoirs : Entity `Homework` (PDF joint, date limite). Rendu élève (upload).
- Examens : Entity `Exam` (calendrier, salle, surveillant, résultats).

### Phase 6 — Communication
- Messagerie : Chat privé enseignant↔parent/élève, admin↔parent. WebSocket STOMP ou polling. FCM.

### Phase 7 — Documents & Paiements
- Documents : Upload/consultation PDF via S3/Cloudinary.
- Paiements : Entity `Payment` (frais, historique, factures, reçus). Consultation parent.

### Phase 8 — Dashboards
- Endpoints agrégés + écran Flutter par rôle.

---

## Tables BDD principales
`users, roles, students, parents, teachers, classes, subjects, schedules, grades, exams, homework, attendance, announcements, messages, notifications, payments, documents`

---

## Astuces anti-gaspillage de tokens
- Valider/committer chaque module avant de passer au suivant.
- Ne jamais redemander "génère toute l'appli".
- Corriger immédiatement si l'agent part dans une mauvaise direction.

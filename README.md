# Atlas Boutique : application e-commerce MVC2 + JPA

Atelier JEE 2 (FST Tanger, LSI, Pr. Elaachak). Une petite boutique en ligne construite avec des servlets et des JSP (patron MVC2) et une persistance JPA (EclipseLink) sur MySQL.

Périmètre : internaute (client ou administrateur), vitrine, catégories, produits, panier. La commande n'est pas réalisée (voir *Limites*).

> **Rapport du projet** : [docs/rapport/rapport_atelier_jee2.pdf](docs/rapport/rapport_atelier_jee2.pdf) (conception, persistance, services, sécurité, tests, limites). Les sources LaTeX sont dans [`docs/rapport`](docs/rapport).

## Fonctionnalités

| Profil | Ce qu'il peut faire |
|---|---|
| Visiteur | Parcourir la vitrine, filtrer par catégorie, rechercher, voir la fiche d'un produit, créer un compte, se connecter |
| Client | Ajouter au panier (mini-panier sans rechargement), modifier une quantité, retirer une ligne, vider le panier |
| Administrateur | Créer, modifier, retirer de la vente et supprimer des produits ; gérer les catégories |

## Technologies

| Rôle | Choix |
|---|---|
| Langage | Java 17 (code compilé en niveau 11, voir *Notes techniques*) |
| Web | Servlet 4.0, JSP 2.3, JSTL 1.2, jQuery 3.7 (livré dans l'application) |
| Persistance | JPA 2.2, EclipseLink 2.7.5, MySQL 8, pilote Connector/J 8.0.33 |
| Injection | CDI 2.0 avec Weld Servlet 3.1.9 |
| Serveur | Apache Tomcat 9.0.x |
| Build | Maven 3.9 |

## Prérequis

JDK 17, Maven 3.9, MySQL 8, Tomcat 9, Eclipse IDE for Enterprise Java Developers (ou tout IDE capable de déployer un WAR sur Tomcat).

## Installation

### 1. Créer la base

```powershell
mysql -u root -p -e "CREATE DATABASE ecommerce_jpa CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### 2. Renseigner les identifiants

Copier le modèle puis y mettre le mot de passe MySQL. Le fichier `db.properties` est ignoré par Git : il ne doit jamais être versionné.

```powershell
Copy-Item src\main\resources\db.properties.example src\main\resources\db.properties
notepad src\main\resources\db.properties
```

### 3. Créer le schéma et les données de démonstration

Dans Eclipse : clic droit sur `ma.fstt.persistence.SchemaTool` → *Run As → Java Application*, puis taper `RESET` à l'invite.
L'outil crée les tables, applique les contraintes (`db/constraints.sql`) et charge les données de test.

### 4. Construire et déployer

```powershell
mvn clean package
```

Le WAR est produit dans `target/`. Dans Eclipse : *Add and Remove* sur le serveur Tomcat 9, port **8081**, puis *Start*.
Au démarrage, la console doit afficher `WELD-ENV-001100` puis la connexion EclipseLink réussie.

Application : <http://localhost:8081/ecommerce-jpa-mvc2/>

## Comptes de démonstration

| Rôle | Adresse | Mot de passe |
|---|---|---|
| Administrateur | `admin@example.com` | `Admin#2026` |
| Client (panier rempli) | `yasmine@example.com` | `Client#2026` |
| Client (panier vide) | `omar@example.com` | `Client#2026` |

Ces comptes sont réservés au développement.

## Tests

Les contrôles automatiques se lancent depuis Eclipse : clic droit sur `ma.fstt.testing.Verifications` → *Run As → Java Application*. Ils ne nécessitent pas la base de données et se terminent par un bilan (succès / échecs).

Un parcours manuel, avec un scénario par règle de gestion, est décrit dans le rapport (chapitre *Tests et validation*).

## Structure

```
src/main/java/ma/fstt/
  entities/      entités JPA (Internaute, Client, Administrateur, Vitrine, Categorie, Produit, Panier, LignePanier)
  service/       interfaces de service, validation, formulaires
  jpa/           implémentations JPA, transactions, fabrique d'EntityManager (CDI)
  web/           servlets (contrôleurs), filtres de sécurité, utilitaires
  util/          hachage des mots de passe, montants, limitation des tentatives
  persistence/   configuration JPA, outil de création du schéma
src/main/webapp/WEB-INF/
  views/         pages JSP        tags/   gabarits (layout, champ, csrf, ...)
docs/            diagramme de classes
docs/rapport/    rapport (PDF, sources LaTeX, captures)
```

## Rapport

Le rapport détaille les décisions et leurs raisons, avec des captures de chaque étape :

| Contenu | Où |
|---|---|
| Rapport au format PDF | [`docs/rapport/rapport_atelier_jee2.pdf`](docs/rapport/rapport_atelier_jee2.pdf) |
| Sources LaTeX (à compiler avec pdfLaTeX, deux fois) | [`docs/rapport/main.tex`](docs/rapport/main.tex) et `docs/rapport/chapitres/` |
| Captures d'écran | `docs/rapport/figures/` |
| Diagramme de classes (Mermaid et TikZ) | `docs/` |

Chapitres : conception, environnement et Maven, persistance, services et CDI, couche web MVC2, vues, sécurité, tests, gestion de version, limites et perspectives.

## Décisions de conception

- **Héritage `SINGLE_TABLE`** pour `Internaute` : la connexion lit un compte sans savoir son rôle à l'avance, une seule table évite toute jointure.
- **Règles du panier dans l'entité `Panier`** (quantité de 1 à 99, produit actif, stock, fusion de lignes, prix figé) : une règle ne peut pas être oubliée par un nouvel écran. La base répète les plus importantes (`CHECK`, `UNIQUE`, clés étrangères).
- **Verrouillage optimiste** (`@Version` sur `Produit`) : pas de verrou en base pendant la réflexion de l'utilisateur.
- **Transactions centralisées** dans `TransactionRunner` : une seule façon d'ouvrir, valider, annuler et fermer.
- **Identifiants hors du dépôt** : `db.properties` est ignoré par Git.

## Sécurité

Requêtes paramétrées, échappement de toutes les sorties, jeton CSRF sur chaque POST, nouvel identifiant de session à la connexion, mots de passe hachés (PBKDF2-HMAC-SHA256, 600 000 itérations), limitation des tentatives de connexion, contrôle d'accès par filtre, en-têtes de sécurité et politique CSP sans script en ligne.

## Notes techniques

EclipseLink 2.7.5 lit les entités avec une version d'ASM qui ne comprend pas les classes compilées pour Java 17 (« Unsupported class file major version 61 »). Le projet est donc compilé avec `maven.compiler.release=11` et s'exécute sans problème sur le JDK 17. Des lignes `[EL Severe]` sur les classes du JDK (`Object`, `List`...) peuvent rester dans la console au démarrage : elles sont sans conséquence.

## Limites

Pas de commande (validation du panier), pas de HTTPS ni d'attribut `Secure` sur le cookie de session, limitation des tentatives conservée en mémoire, pas de récupération de mot de passe. Pistes détaillées dans le [rapport](docs/rapport/rapport_atelier_jee2.pdf).

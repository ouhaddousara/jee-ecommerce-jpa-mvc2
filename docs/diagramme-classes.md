# Diagramme de classes : version A (panier, vitrine, internaute)

```mermaid
classDiagram
    direction LR

    class Internaute {
        <<abstract>>
        -Long id
        -String nom
        -String prenom
        -String email
        -String motDePasseHash
        -LocalDateTime dateInscription
    }
    class Client {
        -String adresse
        -String telephone
    }
    class Administrateur {
        -String matricule
    }
    class Vitrine {
        -Long id
        -String titre
        -String description
        -boolean active
    }
    class Categorie {
        -Long id
        -String nom
        -String description
    }
    class Produit {
        -Long id
        -String reference
        -String nom
        -String description
        -BigDecimal prix
        -int stock
        -String imageUrl
        -boolean actif
        -long version
    }
    class Panier {
        -Long id
        -LocalDateTime dateCreation
        -LocalDateTime dateModification
        +ajouterProduit(Produit, int)
        +modifierQuantite(Produit, int)
        +retirerProduit(Produit)
        +vider()
        +getTotal() BigDecimal
    }
    class LignePanier {
        -Long id
        -int quantite
        -BigDecimal prixUnitaire
        +getSousTotal() BigDecimal
    }

    Internaute <|-- Client
    Internaute <|-- Administrateur
    Client "1" -- "1" Panier : possède
    Panier "1" *-- "0..*" LignePanier : contient
    LignePanier "0..*" --> "1" Produit : référence
    Vitrine "1" o-- "0..*" Categorie : présente
    Categorie "1" o-- "0..*" Produit : regroupe
    Administrateur ..> Produit : gère
```

## Lecture rapide des relations

| Relation | Type JPA | Cascade / remarque |
|---|---|---|
| `Internaute` → `Client`, `Administrateur` | `@Inheritance(SINGLE_TABLE)` | Colonne discriminante `TYPE_INTERNAUTE` |
| `Client` 1—1 `Panier` | `@OneToOne` | Le client est le côté propriétaire (`panier_id`), `CascadeType.ALL` |
| `Panier` 1—* `LignePanier` | `@OneToMany(mappedBy = "panier")` | `CascadeType.ALL` + `orphanRemoval = true` |
| `LignePanier` *—1 `Produit` | `@ManyToOne` | Pas de cascade : un produit survit à la ligne |
| `Vitrine` 1—* `Categorie` | `@OneToMany` / `@ManyToOne` | Pas de suppression en cascade des catégories |
| `Categorie` 1—* `Produit` | `@OneToMany` / `@ManyToOne` | Idem |
| `Administrateur` → `Produit` | Dépendance (aucune association persistée) | Représente le droit de gérer le catalogue |

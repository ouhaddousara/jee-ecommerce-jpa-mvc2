-- CHECK constraints that JPA annotations cannot generate.
-- Applied by SchemaTool after the tables are created (MySQL 8.0.16 or later
-- enforces them). One statement per line, terminated by ';'.

ALTER TABLE produit ADD CONSTRAINT chk_produit_prix CHECK (prix >= 0);
ALTER TABLE produit ADD CONSTRAINT chk_produit_stock CHECK (stock >= 0);
ALTER TABLE ligne_panier ADD CONSTRAINT chk_ligne_quantite CHECK (quantite >= 1);
ALTER TABLE ligne_panier ADD CONSTRAINT chk_ligne_prix CHECK (prix_unitaire >= 0);

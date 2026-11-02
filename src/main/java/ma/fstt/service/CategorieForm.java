package ma.fstt.service;

import ma.fstt.entities.Categorie;

/** Raw (string) values of the category form. */
public class CategorieForm {

    private Long id;
    private String nom;
    private String description;

    public static CategorieForm depuis(Categorie categorie) {
        CategorieForm form = new CategorieForm();
        form.id = categorie.getId();
        form.nom = categorie.getNom();
        form.description = categorie.getDescription();
        return form;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}

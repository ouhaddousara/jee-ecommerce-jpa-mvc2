package ma.fstt.web;

import java.io.IOException;

import javax.inject.Inject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ma.fstt.entities.Categorie;
import ma.fstt.exception.MetierException;
import ma.fstt.exception.ValidationException;
import ma.fstt.service.CategorieForm;
import ma.fstt.service.GestionCatalogueService;

/**
 * Category management (administrators only, enforced by AuthFilter).
 * GET: liste (default), nouveau, editer. POST: enregistrer, supprimer.
 */
@WebServlet(name = "CategorieServlet", urlPatterns = "/admin/categories")
public class CategorieServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    private static final String LISTE = "/admin/categories";

    @Inject
    private GestionCatalogueService gestion;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        switch (action(req, "liste")) {
            case "liste":
                req.setAttribute("categories", gestion.categories());
                afficher(req, resp, "admin/categories");
                break;
            case "nouveau":
                afficherFormulaire(req, resp, new CategorieForm(), "Nouvelle catégorie");
                break;
            case "editer":
                Long id = parametreId(req, "id");
                Categorie categorie = id == null ? null : gestion.categorie(id);
                if (categorie == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                afficherFormulaire(req, resp, CategorieForm.depuis(categorie), "Modifier la catégorie");
                break;
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        switch (action(req, "")) {
            case "enregistrer":
                enregistrer(req, resp);
                break;
            case "supprimer":
                supprimer(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void enregistrer(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        CategorieForm form = new CategorieForm();
        form.setId(parametreId(req, "id"));
        form.setNom(parametre(req, "nom"));
        form.setDescription(parametre(req, "description"));
        try {
            Categorie categorie = gestion.enregistrerCategorie(form);
            Flash.succes(req, "Catégorie « " + categorie.getNom() + " » enregistrée.");
            rediriger(req, resp, LISTE);
        } catch (ValidationException e) {
            req.setAttribute("erreurs", e.getErreurs());
            afficherFormulaire(req, resp, form,
                    form.getId() == null ? "Nouvelle catégorie" : "Modifier la catégorie");
        } catch (MetierException e) {
            Flash.erreur(req, e.getMessage());
            rediriger(req, resp, LISTE);
        }
    }

    private void supprimer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Long id = parametreId(req, "id");
        try {
            if (id == null) {
                throw new MetierException("Catégorie invalide.");
            }
            gestion.supprimerCategorie(id);
            Flash.succes(req, "Catégorie supprimée.");
        } catch (MetierException e) {
            Flash.erreur(req, e.getMessage());
        }
        rediriger(req, resp, LISTE);
    }

    private void afficherFormulaire(HttpServletRequest req, HttpServletResponse resp,
                                    CategorieForm form, String titre) throws ServletException, IOException {
        req.setAttribute("form", form);
        req.setAttribute("titrePage", titre);
        afficher(req, resp, "admin/categorie-form");
    }
}

package ma.fstt.web;

import java.io.IOException;

import javax.inject.Inject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ma.fstt.entities.Produit;
import ma.fstt.exception.MetierException;
import ma.fstt.exception.ValidationException;
import ma.fstt.service.GestionCatalogueService;
import ma.fstt.service.ProduitForm;

/**
 * Product management (administrators only, enforced by AuthFilter).
 * GET: liste (default), nouveau, editer. POST: enregistrer, basculer, supprimer.
 */
@WebServlet(name = "ProduitServlet", urlPatterns = "/admin/produits")
public class ProduitServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    private static final String LISTE = "/admin/produits";

    @Inject
    private GestionCatalogueService gestion;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        switch (action(req, "liste")) {
            case "liste":
                req.setAttribute("produits", gestion.tousLesProduits());
                afficher(req, resp, "admin/produits");
                break;
            case "nouveau":
                ProduitForm vide = new ProduitForm();
                vide.setActif(true);
                vide.setStock("0");
                afficherFormulaire(req, resp, vide, "Nouveau produit");
                break;
            case "editer":
                Long id = parametreId(req, "id");
                Produit produit = id == null ? null : gestion.produit(id);
                if (produit == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                afficherFormulaire(req, resp, ProduitForm.depuis(produit), "Modifier le produit");
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
            case "basculer":
                basculer(req, resp);
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
        ProduitForm form = new ProduitForm();
        form.setId(parametreId(req, "id"));
        form.setVersion(version(req));
        form.setReference(parametre(req, "reference"));
        form.setNom(parametre(req, "nom"));
        form.setDescription(parametre(req, "description"));
        form.setPrix(parametre(req, "prix"));
        form.setStock(parametre(req, "stock"));
        form.setImageUrl(parametre(req, "imageUrl"));
        form.setCategorieId(parametre(req, "categorieId"));
        form.setActif(req.getParameter("actif") != null);

        try {
            Produit produit = gestion.enregistrerProduit(form);
            Flash.succes(req, "Produit « " + produit.getNom() + " » enregistré.");
            rediriger(req, resp, LISTE);
        } catch (ValidationException e) {
            req.setAttribute("erreurs", e.getErreurs());
            afficherFormulaire(req, resp, form,
                    form.getId() == null ? "Nouveau produit" : "Modifier le produit");
        } catch (MetierException e) {
            // e.g. someone else edited the product meanwhile: nothing to fix in the form.
            Flash.erreur(req, e.getMessage());
            rediriger(req, resp, LISTE);
        }
    }

    private void basculer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Long id = parametreId(req, "id");
        try {
            if (id == null) {
                throw new MetierException("Produit invalide.");
            }
            boolean actif = gestion.basculerProduit(id);
            Flash.succes(req, actif ? "Produit remis en vente." : "Produit retiré de la vente.");
        } catch (MetierException e) {
            Flash.erreur(req, e.getMessage());
        }
        rediriger(req, resp, LISTE);
    }

    private void supprimer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Long id = parametreId(req, "id");
        try {
            if (id == null) {
                throw new MetierException("Produit invalide.");
            }
            gestion.supprimerProduit(id);
            Flash.succes(req, "Produit supprimé.");
        } catch (MetierException e) {
            Flash.erreur(req, e.getMessage());
        }
        rediriger(req, resp, LISTE);
    }

    private void afficherFormulaire(HttpServletRequest req, HttpServletResponse resp,
                                    ProduitForm form, String titre) throws ServletException, IOException {
        req.setAttribute("form", form);
        req.setAttribute("titrePage", titre);
        req.setAttribute("categories", gestion.categories());
        afficher(req, resp, "admin/produit-form");
    }

    private static long version(HttpServletRequest req) {
        try {
            return Long.parseLong(parametre(req, "version").trim());
        } catch (NumberFormatException e) {
            return -1; // never equals a real version: the save is refused as a conflict
        }
    }
}

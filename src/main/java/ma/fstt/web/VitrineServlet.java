package ma.fstt.web;

import java.io.IOException;

import javax.inject.Inject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ma.fstt.entities.Produit;
import ma.fstt.service.CatalogueService;

/**
 * Public storefront. Actions: liste (default, with ?categorie=, ?q=, ?page=)
 * and detail (?id=). Read-only, so no doPost: the container answers 405.
 */
@WebServlet(name = "VitrineServlet", urlPatterns = "/vitrine")
public class VitrineServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Inject
    private CatalogueService catalogue;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        switch (action(req, "liste")) {
            case "liste":
                liste(req, resp);
                break;
            case "detail":
                detail(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void liste(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long categorieId = parametreId(req, "categorie");
        String recherche = parametre(req, "q").trim();
        int page = parametreEntier(req, "page", 1);

        req.setAttribute("vitrine", catalogue.vitrineActive());
        req.setAttribute("categories", catalogue.categories());
        req.setAttribute("resultat", catalogue.catalogue(categorieId, recherche, page));
        req.setAttribute("categorieId", categorieId);
        req.setAttribute("q", recherche);
        req.setAttribute("retour", retour(req));
        afficher(req, resp, "vitrine/liste");
    }

    private void detail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long id = parametreId(req, "id");
        Produit produit = id == null ? null : catalogue.produitPublic(id);
        if (produit == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        req.setAttribute("produit", produit);
        req.setAttribute("quantiteMax", Math.min(produit.getStock(), ma.fstt.entities.Panier.MAX_QUANTITE_PAR_LIGNE));
        req.setAttribute("retour", retour(req));
        afficher(req, resp, "vitrine/detail");
    }

    /** Current page (path + query), so "add to cart" can bring the user back here. */
    private static String retour(HttpServletRequest req) {
        String requete = req.getQueryString();
        return req.getServletPath() + (requete != null ? "?" + requete : "");
    }
}

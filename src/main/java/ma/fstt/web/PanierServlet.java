package ma.fstt.web;

import java.io.IOException;

import javax.inject.Inject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ma.fstt.entities.Panier;
import ma.fstt.exception.MetierException;
import ma.fstt.service.PanierService;

/**
 * Cart (clients only, enforced by AuthFilter). GET: voir (page) and resume
 * (JSON for the mini-cart). POST: ajouter, modifier, retirer, vider.
 *
 * The client id always comes from the session, never from the request.
 * A request sent by the scripts (X-Requested-With) gets JSON; a plain form
 * post gets Post/Redirect/Get: the shop works with JavaScript turned off.
 */
@WebServlet(name = "PanierServlet", urlPatterns = "/panier")
public class PanierServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Inject
    private PanierService paniers;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long clientId = utilisateur(req).getId();
        switch (action(req, "voir")) {
            case "voir":
                Panier panier = paniers.consulter(clientId);
                memoriserCompteur(req, panier);
                req.setAttribute("panier", panier);
                afficher(req, resp, "panier/panier");
                break;
            case "resume":
                Panier resume = paniers.consulter(clientId);
                memoriserCompteur(req, resume);
                json(resp, HttpServletResponse.SC_OK, PanierJson.depuis(resume, null));
                break;
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = action(req, "");
        if (!action.equals("ajouter") && !action.equals("modifier")
                && !action.equals("retirer") && !action.equals("vider")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        long clientId = utilisateur(req).getId();
        try {
            Panier panier;
            String message;
            switch (action) {
                case "ajouter":
                    panier = paniers.ajouter(clientId, produitId(req), parametreEntier(req, "quantite", 1));
                    message = "Produit ajouté au panier.";
                    break;
                case "modifier":
                    panier = paniers.modifierQuantite(clientId, produitId(req), parametreEntier(req, "quantite", 1));
                    message = "Quantité mise à jour.";
                    break;
                case "retirer":
                    panier = paniers.retirer(clientId, produitId(req));
                    message = "Produit retiré du panier.";
                    break;
                default:
                    panier = paniers.vider(clientId);
                    message = "Panier vidé.";
            }
            memoriserCompteur(req, panier);

            if (estAjax(req)) {
                json(resp, HttpServletResponse.SC_OK, PanierJson.depuis(panier, message));
            } else {
                Flash.succes(req, message);
                // Only "ajouter" may send the user back where they were (e.g. the storefront page).
                String parDefaut = "/panier";
                rediriger(req, resp, action.equals("ajouter")
                        ? cheminSur(req.getParameter("retour"), parDefaut) : parDefaut);
            }
        } catch (MetierException e) {
            if (estAjax(req)) {
                json(resp, 422, PanierJson.erreur(e.getMessage()));
            } else {
                Flash.erreur(req, e.getMessage());
                rediriger(req, resp, action.equals("ajouter")
                        ? cheminSur(req.getParameter("retour"), "/panier") : "/panier");
            }
        }
    }

    private static long produitId(HttpServletRequest req) {
        Long id = parametreId(req, "produitId");
        if (id == null) {
            throw new MetierException("Produit invalide.");
        }
        return id;
    }

    /** Keeps the badge number of the layout in step with the cart. */
    private static void memoriserCompteur(HttpServletRequest req, Panier panier) {
        req.getSession().setAttribute("panierCount", panier.getNombreArticles());
    }
}

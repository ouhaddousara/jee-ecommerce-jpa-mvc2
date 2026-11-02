package ma.fstt.web;

import java.io.IOException;
import java.util.Locale;

import javax.inject.Inject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import ma.fstt.entities.Internaute;
import ma.fstt.exception.MetierException;
import ma.fstt.exception.ValidationException;
import ma.fstt.service.InscriptionForm;
import ma.fstt.service.InternauteService;
import ma.fstt.service.PanierService;
import ma.fstt.util.LoginThrottle;

/**
 * Accounts. Actions: connexion (GET form / POST sign in), inscription
 * (GET form / POST register), deconnexion (POST only: a link could be
 * triggered by a third-party page, a CSRF-protected form cannot).
 */
@WebServlet(name = "ClientServlet", urlPatterns = "/client")
public class ClientServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Inject
    private InternauteService internautes;

    @Inject
    private PanierService paniers;

    /** 5 failed sign-ins per (address + e-mail) in 15 minutes, then a pause. */
    private final transient LoginThrottle throttle = new LoginThrottle(5, 15 * 60 * 1000L);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        switch (action(req, "connexion")) {
            case "connexion":
                if (utilisateur(req) != null) {
                    rediriger(req, resp, "/vitrine");
                    return;
                }
                afficher(req, resp, "client/connexion");
                break;
            case "inscription":
                if (utilisateur(req) != null) {
                    rediriger(req, resp, "/vitrine");
                    return;
                }
                req.setAttribute("form", new InscriptionForm());
                afficher(req, resp, "client/inscription");
                break;
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        switch (action(req, "")) {
            case "connexion":
                connecter(req, resp);
                break;
            case "inscription":
                inscrire(req, resp);
                break;
            case "deconnexion":
                deconnecter(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void connecter(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = parametre(req, "email").trim();
        String cle = req.getRemoteAddr() + "|" + email.toLowerCase(Locale.ROOT);

        long attente = throttle.secondesRestantes(cle);
        if (attente > 0) {
            req.setAttribute("erreur", "Trop de tentatives. Réessaie dans "
                    + ((attente + 59) / 60) + " minute(s).");
            req.setAttribute("email", email);
            afficher(req, resp, "client/connexion");
            return;
        }
        try {
            Internaute internaute = internautes.authentifier(email, parametre(req, "motDePasse"));
            throttle.reussite(cle);
            String cible = ouvrirSession(req, internaute);
            Flash.succes(req, "Bienvenue " + internaute.getPrenom() + " !");
            rediriger(req, resp, cible);
        } catch (MetierException e) {
            throttle.echec(cle);
            req.setAttribute("erreur", e.getMessage());
            req.setAttribute("email", email);
            afficher(req, resp, "client/connexion");
        }
    }

    private void inscrire(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        InscriptionForm form = new InscriptionForm();
        form.setNom(parametre(req, "nom"));
        form.setPrenom(parametre(req, "prenom"));
        form.setEmail(parametre(req, "email"));
        form.setMotDePasse(parametre(req, "motDePasse"));
        form.setConfirmation(parametre(req, "confirmation"));
        form.setAdresse(parametre(req, "adresse"));
        form.setTelephone(parametre(req, "telephone"));
        try {
            Internaute client = internautes.inscrire(form);
            String cible = ouvrirSession(req, client);
            Flash.succes(req, "Compte créé : bienvenue " + client.getPrenom() + " !");
            rediriger(req, resp, cible);
        } catch (ValidationException e) {
            req.setAttribute("erreurs", e.getErreurs());
            // The passwords are deliberately NOT sent back to the page.
            form.setMotDePasse(null);
            form.setConfirmation(null);
            req.setAttribute("form", form);
            afficher(req, resp, "client/inscription");
        }
    }

    private void deconnecter(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        Flash.info(req, "Tu es déconnecté(e). À bientôt !");
        rediriger(req, resp, "/vitrine");
    }

    /**
     * Starts an authenticated session and returns where to go next.
     * The session id is changed (session fixation) and the CSRF token rotated.
     */
    private String ouvrirSession(HttpServletRequest req, Internaute internaute) {
        HttpSession ancienne = req.getSession(true);
        String retour = (String) ancienne.getAttribute("retour");
        req.changeSessionId();

        HttpSession session = req.getSession();
        session.removeAttribute("retour");
        SessionUser user = SessionUser.de(internaute);
        session.setAttribute(SessionUser.CLE, user);
        SecurityFilter.nouveauJeton(session);
        session.setAttribute("panierCount",
                user.isClient() ? paniers.consulter(user.getId()).getNombreArticles() : 0);

        if (user.isAdmin()) {
            return "/admin/produits";
        }
        String chemin = cheminSur(retour, "/vitrine");
        return chemin.startsWith("/admin") ? "/vitrine" : chemin;
    }
}

package ma.fstt.web;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Shared plumbing of the MVC2 controllers. A controller reads the request,
 * calls a service, puts the result in request attributes and forwards to a
 * JSP under WEB-INF (never reachable directly from the browser).
 */
public abstract class BaseServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VUES = "/WEB-INF/views/";

    /** The ?action= (or action field) of the request, or the default one. */
    protected static String action(HttpServletRequest req, String parDefaut) {
        String action = req.getParameter("action");
        return (action == null || action.isBlank()) ? parDefaut : action.trim();
    }

    protected static void afficher(HttpServletRequest req, HttpServletResponse resp, String vue)
            throws ServletException, IOException {
        req.getRequestDispatcher(VUES + vue + ".jsp").forward(req, resp);
    }

    /** Redirect to a path of this application (Post/Redirect/Get). */
    protected static void rediriger(HttpServletRequest req, HttpServletResponse resp, String chemin)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + chemin);
    }

    protected static SessionUser utilisateur(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (SessionUser) session.getAttribute(SessionUser.CLE);
    }

    /** Parses a positive id; null when absent or malformed (never throws). */
    protected static Long parametreId(HttpServletRequest req, String nom) {
        try {
            long valeur = Long.parseLong(req.getParameter(nom).trim());
            return valeur > 0 ? valeur : null;
        } catch (RuntimeException e) {
            return null; // null parameter, not a number or out of range
        }
    }

    /** The default when absent; 0 (rejected later by the business rules) when malformed. */
    protected static int parametreEntier(HttpServletRequest req, String nom, int parDefaut) {
        String brut = req.getParameter(nom);
        if (brut == null || brut.isBlank()) {
            return parDefaut;
        }
        try {
            return Integer.parseInt(brut.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    protected static String parametre(HttpServletRequest req, String nom) {
        String valeur = req.getParameter(nom);
        return valeur == null ? "" : valeur;
    }

    /** True for the requests sent by the jQuery scripts, which expect JSON. */
    protected static boolean estAjax(HttpServletRequest req) {
        return "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
    }

    protected static void json(HttpServletResponse resp, int statut, String corps) throws IOException {
        resp.setStatus(statut);
        resp.setContentType("application/json");
        resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
        resp.getWriter().write(corps);
    }

    /**
     * Only a path inside this application is accepted as a redirect target
     * (starts with a single "/", no scheme, no backslash, no line break):
     * this closes the open-redirect hole of a user-supplied "retour" field.
     */
    protected static String cheminSur(String chemin, String parDefaut) {
        if (chemin == null || !chemin.startsWith("/") || chemin.startsWith("//")
                || chemin.indexOf('\\') >= 0 || chemin.indexOf('\r') >= 0 || chemin.indexOf('\n') >= 0) {
            return parDefaut;
        }
        return chemin;
    }
}

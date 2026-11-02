package ma.fstt.web;

import java.io.Serializable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * One-shot message shown after a redirect (Post/Redirect/Get). It is stored
 * in the session before the redirect, and moved to a request attribute by
 * SecurityFilter on the next page view, so it displays once and never again.
 */
public final class Flash {

    private static final String CLE = "flash";

    private Flash() {
    }

    /** Value object read by the JSP as ${flash.type} / ${flash.texte}. */
    public static final class Message implements Serializable {

        private static final long serialVersionUID = 1L;

        private final String type;
        private final String texte;

        Message(String type, String texte) {
            this.type = type;
            this.texte = texte;
        }

        /** "success", "error" or "info": used as a CSS class. */
        public String getType() {
            return type;
        }

        public String getTexte() {
            return texte;
        }
    }

    public static void succes(HttpServletRequest req, String texte) {
        poser(req, "success", texte);
    }

    public static void erreur(HttpServletRequest req, String texte) {
        poser(req, "error", texte);
    }

    public static void info(HttpServletRequest req, String texte) {
        poser(req, "info", texte);
    }

    private static void poser(HttpServletRequest req, String type, String texte) {
        req.getSession(true).setAttribute(CLE, new Message(type, texte));
    }

    /** Moves the pending message (if any) from the session to the request, removing it from the session. */
    static void transferer(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return;
        }
        Object message = session.getAttribute(CLE);
        if (message != null) {
            session.removeAttribute(CLE);
            req.setAttribute(CLE, message);
        }
    }
}

package ma.fstt.web;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Access control, applied to /panier (clients only) and /admin/* (administrators only).
 * It sits in front of the controllers, so a new admin page is protected as
 * soon as it is mapped under /admin, without anyone having to remember a check.
 */
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        SessionUser user = session == null ? null : (SessionUser) session.getAttribute(SessionUser.CLE);
        boolean zoneAdmin = req.getServletPath().startsWith("/admin");
        String connexion = req.getContextPath() + "/client?action=connexion";

        if (user == null) {
            if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json");
                resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
                resp.getWriter().write(PanierJson.connexionRequise(connexion));
                return;
            }
            // Remember where to come back after signing in (GET only, path built here, not user-supplied).
            if ("GET".equals(req.getMethod())) {
                String retour = req.getServletPath()
                        + (req.getQueryString() != null ? "?" + req.getQueryString() : "");
                req.getSession(true).setAttribute("retour", retour);
            }
            Flash.info(req, "Connecte-toi pour continuer.");
            resp.sendRedirect(connexion);
            return;
        }

        if (zoneAdmin ? !user.isAdmin() : !user.isClient()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Cette page n'est pas accessible avec ton compte.");
            return;
        }
        chain.doFilter(request, response);
    }
}

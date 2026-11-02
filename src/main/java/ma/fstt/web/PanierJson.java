package ma.fstt.web;

import ma.fstt.entities.LignePanier;
import ma.fstt.entities.Panier;
import ma.fstt.entities.Produit;
import ma.fstt.util.Money;

/**
 * Hand-written JSON for the mini-cart (no JSON library is needed for a
 * payload this small). Amounts are pre-formatted strings, so the browser
 * script never does money arithmetic.
 */
public final class PanierJson {

    private PanierJson() {
    }

    /** Cart state; {@code message} may be null. */
    public static String depuis(Panier panier, String message) {
        StringBuilder sb = new StringBuilder(512);
        sb.append("{\"ok\":true");
        if (message != null) {
            sb.append(",\"message\":");
            chaine(sb, message);
        }
        sb.append(",\"nombreArticles\":").append(panier.getNombreArticles());
        sb.append(",\"total\":");
        chaine(sb, Money.format(panier.getTotal()));
        sb.append(",\"lignes\":[");
        boolean premiere = true;
        for (LignePanier ligne : panier.getLignes()) {
            if (!premiere) {
                sb.append(',');
            }
            premiere = false;
            Produit produit = ligne.getProduit();
            sb.append("{\"produitId\":").append(produit.getId());
            sb.append(",\"reference\":");
            chaine(sb, produit.getReference());
            sb.append(",\"nom\":");
            chaine(sb, produit.getNom());
            sb.append(",\"quantite\":").append(ligne.getQuantite());
            sb.append(",\"stock\":").append(produit.getStock());
            sb.append(",\"prixUnitaire\":");
            chaine(sb, Money.format(ligne.getPrixUnitaire()));
            sb.append(",\"sousTotal\":");
            chaine(sb, Money.format(ligne.getSousTotal()));
            sb.append(",\"ton\":").append(produit.getCategorie().getId() % 6);
            sb.append('}');
        }
        sb.append("]}");
        return sb.toString();
    }

    public static String erreur(String message) {
        StringBuilder sb = new StringBuilder("{\"ok\":false,\"message\":");
        chaine(sb, message);
        return sb.append('}').toString();
    }

    /** Answer for an anonymous visitor: tells the script where to send them. */
    public static String connexionRequise(String urlConnexion) {
        StringBuilder sb = new StringBuilder("{\"ok\":false,\"connexion\":");
        chaine(sb, urlConnexion);
        return sb.append('}').toString();
    }

    /** Appends a JSON string literal. Also escapes &lt; &gt; &amp; so the payload is safe anywhere it ends up. */
    static void chaine(StringBuilder sb, String valeur) {
        sb.append('"');
        for (int i = 0; i < valeur.length(); i++) {
            char c = valeur.charAt(i);
            switch (c) {
                case '"':
                    sb.append("\\\"");
                    break;
                case '\\':
                    sb.append("\\\\");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                case '<':
                case '>':
                case '&':
                case ' ':
                case ' ':
                    sb.append(String.format("\\u%04x", (int) c));
                    break;
                default:
                    if (c < 0x20) {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        sb.append('"');
    }
}

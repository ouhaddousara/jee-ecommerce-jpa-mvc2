package ma.fstt.web;

import static ma.fstt.testing.Checks.check;
import static ma.fstt.testing.Checks.section;

import java.io.IOException;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import ma.fstt.entities.Categorie;
import ma.fstt.entities.Panier;
import ma.fstt.entities.Produit;
import ma.fstt.entities.Vitrine;

/** Redirect safety, CSRF comparison and the JSON given to the mini-cart. */
public final class WebChecks {

    private WebChecks() {
    }

    public static void executer() throws Exception {
        section("Redirection sûre (anti open-redirect)");
        check("chemin interne accepté", "/vitrine?categorie=2".equals(BaseServlet.cheminSur("/vitrine?categorie=2", "/x")));
        check("//site-externe refusé", "/x".equals(BaseServlet.cheminSur("//evil.example", "/x")));
        check("URL absolue refusée", "/x".equals(BaseServlet.cheminSur("https://evil.example", "/x")));
        check("chemin sans / initial refusé", "/x".equals(BaseServlet.cheminSur("vitrine", "/x")));
        check("antislash refusé", "/x".equals(BaseServlet.cheminSur("/\\evil.example", "/x")));
        check("saut de ligne refusé (injection d'en-tête)",
                "/x".equals(BaseServlet.cheminSur("/a\r\nSet-Cookie: x=1", "/x")));
        check("null refusé", "/x".equals(BaseServlet.cheminSur(null, "/x")));

        section("Jeton CSRF");
        check("jetons identiques", SecurityFilter.egal("abc123", "abc123"));
        check("jetons différents", !SecurityFilter.egal("abc123", "abc124"));
        check("jeton absent refusé", !SecurityFilter.egal("abc123", null) && !SecurityFilter.egal(null, "abc123"));
        check("longueurs différentes refusées", !SecurityFilter.egal("abc123", "abc"));

        section("JSON du mini-panier");
        Vitrine vitrine = new Vitrine("T", "d", true);
        Categorie categorie = vitrine.ajouterCategorie(new Categorie("C", "d"));
        fixerId(Categorie.class, categorie, 8L);
        Produit produit = categorie.ajouterProduit(new Produit("INF-001",
                "Clavier \"pro\" <b>& é\\ligne", "d", new BigDecimal("549.00"), 25, true));
        fixerId(Produit.class, produit, 1L);

        Panier panier = new Panier();
        panier.ajouterProduit(produit, 2);
        String json = PanierJson.depuis(panier, "Produit ajouté au panier.");

        check("pas de < > & bruts dans le JSON", !json.contains("<") && !json.contains(">") && !json.contains("&"));
        check("les guillemets sont échappés", json.contains("Clavier \\\"pro\\\""));
        check("le total est formaté (1 098,00)", json.replaceAll("[^0-9,\"]", "").contains("\"109800\"")
                || json.contains("098,00"));
        check("nombre d'articles = 2", json.contains("\"nombreArticles\":2"));
        check("ton de couleur = id de catégorie modulo 6 (8 donne 2)", json.contains("\"ton\":2"));
        check("erreur : ok à false", PanierJson.erreur("Stock insuffisant").contains("\"ok\":false"));
        check("connexion requise : l'adresse est transmise",
                PanierJson.connexionRequise("/app/client?action=connexion").contains("/app/client?action=connexion"));

        // Written out so a script can feed it to a real JSON parser.
        String sortie = System.getProperty("json.out");
        if (sortie != null) {
            ecrire(sortie, json);
        }
    }

    private static void fixerId(Class<?> type, Object objet, long id) throws Exception {
        Field champ = type.getDeclaredField("id");
        champ.setAccessible(true);
        champ.set(objet, id);
    }

    private static void ecrire(String chemin, String contenu) throws IOException {
        Files.write(Paths.get(chemin), contenu.getBytes(StandardCharsets.UTF_8));
    }
}

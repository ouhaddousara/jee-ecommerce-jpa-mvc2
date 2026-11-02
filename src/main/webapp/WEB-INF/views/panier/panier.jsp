<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<t:layout titre="Mon panier" nav="panier">

<h1 class="titre-page">Mon panier</h1>

<c:choose>
  <c:when test="${panier.vide}">
    <t:vide illustration="panier" titre="Ton panier est vide"
            texte="Parcours la vitrine et ajoute les produits qui te plaisent.">
      <a class="btn btn-primary" href="${ctx}/vitrine">Découvrir la vitrine</a>
    </t:vide>
  </c:when>
  <c:otherwise>
    <div class="panier-grille">

      <section class="panier-lignes" aria-label="Articles du panier">
        <c:forEach var="l" items="${panier.lignes}">
          <article class="ligne">
            <a href="${ctx}/vitrine?action=detail&amp;id=${l.produit.id}" tabindex="-1" aria-hidden="true">
              <t:visuel produit="${l.produit}" taille="sm"/>
            </a>

            <div class="ligne-info">
              <h2><a href="${ctx}/vitrine?action=detail&amp;id=${l.produit.id}"><c:out value="${l.produit.nom}"/></a></h2>
              <p class="muted">Réf. <c:out value="${l.produit.reference}"/> · <t:prix valeur="${l.prixUnitaire}"/> l'unité</p>
              <c:if test="${l.quantite >= l.produit.stock}">
                <p class="note-stock">Stock maximum atteint (<c:out value="${l.produit.stock}"/>).</p>
              </c:if>
            </div>

            <form method="post" action="${ctx}/panier" class="ligne-qte">
              <input type="hidden" name="action" value="modifier">
              <input type="hidden" name="produitId" value="${l.produit.id}">
              <t:csrf/>
              <label class="sr-only" for="q-${l.produit.id}">Quantité de <c:out value="${l.produit.nom}"/></label>
              <input id="q-${l.produit.id}" name="quantite" type="number" min="1"
                     max="${l.produit.stock < 99 ? l.produit.stock : 99}" value="${l.quantite}" required>
              <button type="submit" class="btn btn-ghost btn-sm">Mettre à jour</button>
            </form>

            <p class="ligne-total"><t:prix valeur="${l.sousTotal}"/></p>

            <form method="post" action="${ctx}/panier" class="ligne-suppr">
              <input type="hidden" name="action" value="retirer">
              <input type="hidden" name="produitId" value="${l.produit.id}">
              <t:csrf/>
              <button type="submit" class="icon-btn icon-danger" aria-label="Retirer <c:out value='${l.produit.nom}'/> du panier">
                <t:icone nom="corbeille"/>
              </button>
            </form>
          </article>
        </c:forEach>
      </section>

      <aside class="recap" aria-label="Récapitulatif">
        <h2>Récapitulatif</h2>
        <dl>
          <div><dt>Articles</dt><dd><c:out value="${panier.nombreArticles}"/></dd></div>
          <div class="recap-total"><dt>Total</dt><dd><t:prix valeur="${panier.total}"/></dd></div>
        </dl>
        <a class="btn btn-primary btn-block" href="${ctx}/vitrine">Continuer mes achats</a>
        <form method="post" action="${ctx}/panier">
          <input type="hidden" name="action" value="vider">
          <t:csrf/>
          <button type="submit" class="btn btn-danger btn-block"
                  data-confirm="Vider entièrement le panier ?">Vider le panier</button>
        </form>
      </aside>

    </div>
  </c:otherwise>
</c:choose>

</t:layout>

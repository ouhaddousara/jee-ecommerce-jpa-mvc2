<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<t:layout titre="Vitrine" nav="vitrine">

<c:choose>
  <c:when test="${empty vitrine}">
    <t:vide illustration="boite" titre="La vitrine est fermée pour le moment"
            texte="Aucune vitrine n'est active. Reviens un peu plus tard."/>
  </c:when>
  <c:otherwise>

    <section class="hero">
      <p class="eyebrow">Sélection du moment</p>
      <h1><c:out value="${vitrine.titre}"/></h1>
      <p class="hero-texte"><c:out value="${vitrine.description}"/></p>
      <form class="search" method="get" action="${ctx}/vitrine" role="search">
        <c:if test="${not empty categorieId}"><input type="hidden" name="categorie" value="<c:out value='${categorieId}'/>"></c:if>
        <label class="sr-only" for="q">Rechercher un produit</label>
        <t:icone nom="recherche"/>
        <input id="q" type="search" name="q" value="<c:out value='${q}'/>" placeholder="Rechercher un produit, une référence…" maxlength="60">
        <button type="submit" class="btn btn-primary">Rechercher</button>
      </form>
    </section>

    <nav class="chips" aria-label="Catégories">
      <c:url var="urlTous" value="/vitrine"><c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if></c:url>
      <a class="chip${empty categorieId ? ' is-active' : ''}" href="<c:out value='${urlTous}'/>">Tout voir</a>
      <c:forEach var="cat" items="${categories}">
        <c:url var="urlCat" value="/vitrine">
          <c:param name="categorie" value="${cat.id}"/>
          <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
        </c:url>
        <a class="chip${categorieId == cat.id ? ' is-active' : ''}" href="<c:out value='${urlCat}'/>">
          <c:out value="${cat.nom}"/> <span class="chip-n"><c:out value="${cat.nombreProduits}"/></span>
        </a>
      </c:forEach>
    </nav>

    <c:choose>
      <c:when test="${empty resultat.elements}">
        <t:vide illustration="recherche" titre="Aucun produit trouvé"
                texte="Essaie un autre mot-clé ou retire le filtre de catégorie.">
          <a class="btn btn-primary" href="${ctx}/vitrine">Voir toute la vitrine</a>
        </t:vide>
      </c:when>
      <c:otherwise>
        <p class="compteur">
          <c:out value="${resultat.debut}"/> à <c:out value="${resultat.fin}"/> sur
          <c:out value="${resultat.total}"/> produit(s)
        </p>

        <div class="grille">
          <c:forEach var="p" items="${resultat.elements}">
            <article class="carte">
              <a class="carte-visuel" href="${ctx}/vitrine?action=detail&amp;id=${p.id}" tabindex="-1" aria-hidden="true">
                <t:visuel produit="${p}"/>
              </a>
              <div class="carte-corps">
                <p class="carte-cat"><c:out value="${p.categorie.nom}"/></p>
                <h2 class="carte-titre">
                  <a href="${ctx}/vitrine?action=detail&amp;id=${p.id}"><c:out value="${p.nom}"/></a>
                </h2>
                <div class="carte-ligne">
                  <span class="prix"><t:prix valeur="${p.prix}"/></span>
                  <t:stock stock="${p.stock}"/>
                </div>
                <form method="post" action="${ctx}/panier" class="js-add">
                  <input type="hidden" name="action" value="ajouter">
                  <input type="hidden" name="produitId" value="${p.id}">
                  <input type="hidden" name="quantite" value="1">
                  <input type="hidden" name="retour" value="<c:out value='${retour}'/>">
                  <t:csrf/>
                  <button type="submit" class="btn btn-primary btn-block"${p.stock <= 0 ? ' disabled' : ''}>
                    <t:icone nom="panier"/> <c:out value="${p.stock <= 0 ? 'Indisponible' : 'Ajouter au panier'}"/>
                  </button>
                </form>
              </div>
            </article>
          </c:forEach>
        </div>

        <c:if test="${resultat.totalPages > 1}">
          <nav class="pagination" aria-label="Pagination">
            <c:if test="${resultat.precedente}">
              <c:url var="urlPrec" value="/vitrine">
                <c:if test="${not empty categorieId}"><c:param name="categorie" value="${categorieId}"/></c:if>
                <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
                <c:param name="page" value="${resultat.page - 1}"/>
              </c:url>
              <a href="<c:out value='${urlPrec}'/>" rel="prev"><t:icone nom="retour"/> Précédent</a>
            </c:if>
            <c:forEach var="n" begin="1" end="${resultat.totalPages}">
              <c:url var="urlPage" value="/vitrine">
                <c:if test="${not empty categorieId}"><c:param name="categorie" value="${categorieId}"/></c:if>
                <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
                <c:param name="page" value="${n}"/>
              </c:url>
              <a href="<c:out value='${urlPage}'/>"${n == resultat.page ? ' class="is-active" aria-current="page"' : ''}><c:out value="${n}"/></a>
            </c:forEach>
            <c:if test="${resultat.suivante}">
              <c:url var="urlSuiv" value="/vitrine">
                <c:if test="${not empty categorieId}"><c:param name="categorie" value="${categorieId}"/></c:if>
                <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
                <c:param name="page" value="${resultat.page + 1}"/>
              </c:url>
              <a href="<c:out value='${urlSuiv}'/>" rel="next">Suivant</a>
            </c:if>
          </nav>
        </c:if>
      </c:otherwise>
    </c:choose>

  </c:otherwise>
</c:choose>

</t:layout>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<t:layout titre="${produit.nom}" nav="vitrine">

<nav class="fil" aria-label="Fil d'Ariane">
  <a href="${ctx}/vitrine">Vitrine</a>
  <span aria-hidden="true">/</span>
  <a href="${ctx}/vitrine?categorie=${produit.categorie.id}"><c:out value="${produit.categorie.nom}"/></a>
</nav>

<article class="detail">
  <div class="detail-visuel">
    <t:visuel produit="${produit}" taille="lg"/>
  </div>

  <div class="detail-corps">
    <p class="carte-cat"><c:out value="${produit.categorie.nom}"/> · Réf. <c:out value="${produit.reference}"/></p>
    <h1><c:out value="${produit.nom}"/></h1>
    <p class="detail-prix"><t:prix valeur="${produit.prix}"/></p>
    <p><t:stock stock="${produit.stock}"/></p>

    <c:if test="${not empty produit.description}">
      <p class="detail-texte"><c:out value="${produit.description}"/></p>
    </c:if>

    <c:choose>
      <c:when test="${produit.stock > 0}">
        <form method="post" action="${ctx}/panier" class="detail-form js-add">
          <input type="hidden" name="action" value="ajouter">
          <input type="hidden" name="produitId" value="${produit.id}">
          <input type="hidden" name="retour" value="<c:out value='${retour}'/>">
          <t:csrf/>
          <div class="champ champ-court">
            <label for="quantite">Quantité</label>
            <input id="quantite" name="quantite" type="number" min="1" max="${quantiteMax}" value="1" required>
          </div>
          <button type="submit" class="btn btn-primary btn-lg"><t:icone nom="panier"/> Ajouter au panier</button>
        </form>
      </c:when>
      <c:otherwise>
        <p class="alerte">Ce produit est épuisé pour le moment.</p>
      </c:otherwise>
    </c:choose>

    <p><a class="lien-retour" href="${ctx}/vitrine"><t:icone nom="retour"/> Retour à la vitrine</a></p>
  </div>
</article>

</t:layout>

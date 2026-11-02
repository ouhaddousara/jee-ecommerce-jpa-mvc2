<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<t:layout titre="Produits" nav="produits">

<div class="entete">
  <div>
    <p class="eyebrow">Administration</p>
    <h1 class="titre-page">Produits</h1>
  </div>
  <a class="btn btn-primary" href="${ctx}/admin/produits?action=nouveau"><t:icone nom="plus"/> Nouveau produit</a>
</div>

<c:choose>
  <c:when test="${empty produits}">
    <t:vide illustration="boite" titre="Aucun produit" texte="Le catalogue est vide.">
      <a class="btn btn-primary" href="${ctx}/admin/produits?action=nouveau">Ajouter le premier produit</a>
    </t:vide>
  </c:when>
  <c:otherwise>
    <div class="tableau-cadre">
      <table class="tableau">
        <thead>
          <tr>
            <th scope="col">Produit</th>
            <th scope="col">Catégorie</th>
            <th scope="col" class="num">Prix</th>
            <th scope="col" class="num">Stock</th>
            <th scope="col">État</th>
            <th scope="col"><span class="sr-only">Actions</span></th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="p" items="${produits}">
            <tr>
              <td>
                <div class="cellule-produit">
                  <t:visuel produit="${p}" taille="sm"/>
                  <div>
                    <strong><c:out value="${p.nom}"/></strong>
                    <span class="muted"><c:out value="${p.reference}"/></span>
                  </div>
                </div>
              </td>
              <td><c:out value="${p.categorie.nom}"/></td>
              <td class="num"><t:prix valeur="${p.prix}"/></td>
              <td class="num"><c:out value="${p.stock}"/></td>
              <td>
                <span class="pill ${p.actif ? 'pill-ok' : 'pill-off'}"><c:out value="${p.actif ? 'En vente' : 'Retiré'}"/></span>
              </td>
              <td>
                <div class="actions">
                  <a class="btn btn-ghost btn-sm" href="${ctx}/admin/produits?action=editer&amp;id=${p.id}">Modifier</a>
                  <form method="post" action="${ctx}/admin/produits">
                    <input type="hidden" name="action" value="basculer">
                    <input type="hidden" name="id" value="${p.id}">
                    <t:csrf/>
                    <button type="submit" class="btn btn-ghost btn-sm"><c:out value="${p.actif ? 'Retirer' : 'Remettre'}"/></button>
                  </form>
                  <form method="post" action="${ctx}/admin/produits">
                    <input type="hidden" name="action" value="supprimer">
                    <input type="hidden" name="id" value="${p.id}">
                    <t:csrf/>
                    <button type="submit" class="btn btn-danger btn-sm"
                            data-confirm="Supprimer définitivement ce produit ?">Supprimer</button>
                  </form>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </c:otherwise>
</c:choose>

</t:layout>

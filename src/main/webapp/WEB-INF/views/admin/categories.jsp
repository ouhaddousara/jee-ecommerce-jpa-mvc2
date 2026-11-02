<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<t:layout titre="Catégories" nav="categories">

<div class="entete">
  <div>
    <p class="eyebrow">Administration</p>
    <h1 class="titre-page">Catégories</h1>
  </div>
  <a class="btn btn-primary" href="${ctx}/admin/categories?action=nouveau"><t:icone nom="plus"/> Nouvelle catégorie</a>
</div>

<c:choose>
  <c:when test="${empty categories}">
    <t:vide illustration="boite" titre="Aucune catégorie" texte="Crée une première catégorie pour ranger les produits.">
      <a class="btn btn-primary" href="${ctx}/admin/categories?action=nouveau">Créer une catégorie</a>
    </t:vide>
  </c:when>
  <c:otherwise>
    <div class="tableau-cadre">
      <table class="tableau">
        <thead>
          <tr>
            <th scope="col">Catégorie</th>
            <th scope="col">Description</th>
            <th scope="col" class="num">Produits</th>
            <th scope="col"><span class="sr-only">Actions</span></th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="cat" items="${categories}">
            <tr>
              <td><strong><c:out value="${cat.nom}"/></strong></td>
              <td class="muted"><c:out value="${cat.description}"/></td>
              <td class="num"><c:out value="${cat.nombreProduits}"/></td>
              <td>
                <div class="actions">
                  <a class="btn btn-ghost btn-sm" href="${ctx}/admin/categories?action=editer&amp;id=${cat.id}">Modifier</a>
                  <form method="post" action="${ctx}/admin/categories">
                    <input type="hidden" name="action" value="supprimer">
                    <input type="hidden" name="id" value="${cat.id}">
                    <t:csrf/>
                    <button type="submit" class="btn btn-danger btn-sm"
                            data-confirm="Supprimer cette catégorie ?">Supprimer</button>
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

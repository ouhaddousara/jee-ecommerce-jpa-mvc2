<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<t:layout titre="${titrePage}" nav="produits">

<div class="entete">
  <div>
    <p class="eyebrow">Administration</p>
    <h1 class="titre-page"><c:out value="${titrePage}"/></h1>
  </div>
</div>

<section class="formulaire">
  <c:if test="${not empty erreurs}">
    <p class="alerte alerte-erreur" role="alert">Le formulaire contient des erreurs : corrige les champs signalés.</p>
  </c:if>

  <form method="post" action="${ctx}/admin/produits" novalidate>
    <input type="hidden" name="action" value="enregistrer">
    <%-- id and version: the version lets the service refuse a save based on an outdated copy --%>
    <input type="hidden" name="id" value="<c:out value='${form.id}'/>">
    <input type="hidden" name="version" value="<c:out value='${form.version}'/>">
    <t:csrf/>

    <div class="deux-col">
      <t:champ nom="reference" libelle="Référence" valeur="${form.reference}" erreurs="${erreurs}"
               requis="true" maxlength="40" aide="Lettres, chiffres, point et tiret. Exemple : INF-004."/>
      <t:champ nom="nom" libelle="Nom du produit" valeur="${form.nom}" erreurs="${erreurs}"
               requis="true" maxlength="150"/>
    </div>

    <t:champ nom="description" libelle="Description" valeur="${form.description}" erreurs="${erreurs}"
             multiligne="true" maxlength="2000" aide="Facultatif."/>

    <div class="trois-col">
      <t:champ nom="prix" libelle="Prix (MAD)" valeur="${form.prix}" erreurs="${erreurs}"
               requis="true" aide="Exemple : 129,90"/>
      <t:champ nom="stock" libelle="Stock" type="number" valeur="${form.stock}" erreurs="${erreurs}"
               requis="true" min="0" step="1"/>
      <div class="champ${not empty erreurs['categorieId'] ? ' has-error' : ''}">
        <label for="f-categorieId">Catégorie <span class="req" title="obligatoire">*</span></label>
        <select id="f-categorieId" name="categorieId" required>
          <option value="">Choisir…</option>
          <c:forEach var="cat" items="${categories}">
            <option value="${cat.id}"${form.categorieId eq cat.id.toString() ? ' selected' : ''}><c:out value="${cat.nom}"/></option>
          </c:forEach>
        </select>
        <c:if test="${not empty erreurs['categorieId']}"><p class="erreur"><c:out value="${erreurs['categorieId']}"/></p></c:if>
      </div>
    </div>

    <t:champ nom="imageUrl" libelle="Adresse de l'image" type="url" valeur="${form.imageUrl}" erreurs="${erreurs}"
             maxlength="255" aide="Facultatif, en https. Sans image, un visuel coloré est affiché."/>

    <label class="case">
      <input type="checkbox" name="actif" value="on"${form.actif ? ' checked' : ''}>
      <span>En vente (visible dans la vitrine)</span>
    </label>

    <div class="formulaire-actions">
      <button type="submit" class="btn btn-primary btn-lg">Enregistrer</button>
      <a class="btn btn-ghost btn-lg" href="${ctx}/admin/produits">Annuler</a>
    </div>
  </form>
</section>

</t:layout>

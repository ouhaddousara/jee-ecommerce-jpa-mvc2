<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<t:layout titre="${titrePage}" nav="categories">

<div class="entete">
  <div>
    <p class="eyebrow">Administration</p>
    <h1 class="titre-page"><c:out value="${titrePage}"/></h1>
  </div>
</div>

<section class="formulaire formulaire-etroit">
  <c:if test="${not empty erreurs}">
    <p class="alerte alerte-erreur" role="alert">Le formulaire contient des erreurs : corrige les champs signalés.</p>
  </c:if>

  <form method="post" action="${ctx}/admin/categories" novalidate>
    <input type="hidden" name="action" value="enregistrer">
    <input type="hidden" name="id" value="<c:out value='${form.id}'/>">
    <t:csrf/>
    <t:champ nom="nom" libelle="Nom" valeur="${form.nom}" erreurs="${erreurs}" requis="true" maxlength="100"/>
    <t:champ nom="description" libelle="Description" valeur="${form.description}" erreurs="${erreurs}"
             multiligne="true" maxlength="255" aide="Facultatif."/>
    <div class="formulaire-actions">
      <button type="submit" class="btn btn-primary btn-lg">Enregistrer</button>
      <a class="btn btn-ghost btn-lg" href="${ctx}/admin/categories">Annuler</a>
    </div>
  </form>
</section>

</t:layout>

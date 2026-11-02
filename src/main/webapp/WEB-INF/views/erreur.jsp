<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="code" value="${requestScope['javax.servlet.error.status_code']}"/>
<c:set var="detail" value="${requestScope['javax.servlet.error.message']}"/>
<t:layout titre="Erreur ${code}" nav="">

<c:choose>
  <c:when test="${code == 404}">
    <c:set var="titreErreur" value="Page introuvable"/>
    <c:set var="texteErreur" value="Cette page n'existe pas ou n'existe plus."/>
  </c:when>
  <c:when test="${code == 403}">
    <c:set var="titreErreur" value="Accès refusé"/>
    <c:set var="texteErreur" value="${empty detail ? 'Tu n’as pas le droit d’ouvrir cette page.' : detail}"/>
  </c:when>
  <c:when test="${code == 405}">
    <c:set var="titreErreur" value="Action non autorisée"/>
    <c:set var="texteErreur" value="Cette adresse n'accepte pas ce type de requête."/>
  </c:when>
  <c:otherwise>
    <c:set var="titreErreur" value="Une erreur est survenue"/>
    <c:set var="texteErreur" value="Le problème a été enregistré. Réessaie dans un instant."/>
  </c:otherwise>
</c:choose>

<t:vide illustration="recherche" titre="${titreErreur}" texte="${texteErreur}">
  <a class="btn btn-primary" href="${ctx}/vitrine">Retour à la vitrine</a>
</t:vide>
<p class="code-erreur">Code <c:out value="${empty code ? 500 : code}"/></p>

</t:layout>

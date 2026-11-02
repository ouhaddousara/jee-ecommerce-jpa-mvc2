<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" description="Form field with its label and its validation message" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ attribute name="nom" required="true" description="Field name (also the key in the errors map)" %>
<%@ attribute name="libelle" required="true" %>
<%@ attribute name="valeur" required="false" %>
<%@ attribute name="erreurs" required="false" type="java.util.Map" %>
<%@ attribute name="type" required="false" %>
<%@ attribute name="requis" required="false" type="java.lang.Boolean" %>
<%@ attribute name="multiligne" required="false" type="java.lang.Boolean" %>
<%@ attribute name="aide" required="false" %>
<%@ attribute name="autocomplete" required="false" %>
<%@ attribute name="maxlength" required="false" %>
<%@ attribute name="min" required="false" %>
<%@ attribute name="step" required="false" %>
<c:set var="erreur" value="${erreurs[nom]}"/>
<div class="champ${not empty erreur ? ' has-error' : ''}">
  <label for="f-${nom}"><c:out value="${libelle}"/><c:if test="${requis}"> <span class="req" title="obligatoire">*</span></c:if></label>
  <c:choose>
    <c:when test="${multiligne}">
      <textarea id="f-${nom}" name="${nom}" rows="4"<c:if test="${not empty maxlength}"> maxlength="${maxlength}"</c:if><c:if test="${not empty erreur}"> aria-invalid="true" aria-describedby="e-${nom}"</c:if>><c:out value="${valeur}"/></textarea>
    </c:when>
    <c:otherwise>
      <input id="f-${nom}" name="${nom}" type="${empty type ? 'text' : type}" value="<c:out value='${valeur}'/>"<c:if test="${requis}"> required</c:if><c:if test="${not empty autocomplete}"> autocomplete="${autocomplete}"</c:if><c:if test="${not empty maxlength}"> maxlength="${maxlength}"</c:if><c:if test="${not empty min}"> min="${min}"</c:if><c:if test="${not empty step}"> step="${step}"</c:if><c:if test="${not empty erreur}"> aria-invalid="true" aria-describedby="e-${nom}"</c:if>>
    </c:otherwise>
  </c:choose>
  <c:if test="${not empty aide and empty erreur}"><p class="aide"><c:out value="${aide}"/></p></c:if>
  <c:if test="${not empty erreur}"><p class="erreur" id="e-${nom}"><c:out value="${erreur}"/></p></c:if>
</div>

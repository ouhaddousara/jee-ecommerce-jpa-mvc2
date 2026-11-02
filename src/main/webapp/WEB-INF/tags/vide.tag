<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" description="Empty state with an inline illustration; the body holds the call to action" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ attribute name="illustration" required="false" description="panier, recherche or boite" %>
<%@ attribute name="titre" required="true" %>
<%@ attribute name="texte" required="false" %>
<div class="vide">
  <svg class="vide-img" viewBox="0 0 160 120" aria-hidden="true" focusable="false">
    <c:choose>
      <c:when test="${illustration == 'recherche'}">
        <ellipse cx="80" cy="108" rx="44" ry="5" fill="#e3f1ef"/>
        <circle cx="72" cy="54" r="30" fill="#fff" stroke="#0f6e66" stroke-width="3"/>
        <path d="M94 76l24 24" stroke="#0f6e66" stroke-width="7" stroke-linecap="round"/>
        <path d="M56 54h32" stroke="#cfe3df" stroke-width="3" stroke-linecap="round"/>
        <circle cx="122" cy="26" r="8" fill="#e9a820"/>
      </c:when>
      <c:when test="${illustration == 'boite'}">
        <ellipse cx="80" cy="110" rx="48" ry="5" fill="#e3f1ef"/>
        <path d="M30 46l50-22 50 22v44l-50 22-50-22z" fill="#fff" stroke="#0f6e66" stroke-width="3" stroke-linejoin="round"/>
        <path d="M30 46l50 22 50-22M80 68v44" fill="none" stroke="#0f6e66" stroke-width="3" stroke-linejoin="round"/>
        <circle cx="126" cy="22" r="8" fill="#e9a820"/>
      </c:when>
      <c:otherwise>
        <ellipse cx="80" cy="106" rx="46" ry="5" fill="#e3f1ef"/>
        <path d="M34 44h92l-10 48a8 8 0 0 1-8 6H52a8 8 0 0 1-8-6z" fill="#fff" stroke="#0f6e66" stroke-width="3" stroke-linejoin="round"/>
        <path d="M56 44a24 24 0 0 1 48 0" fill="none" stroke="#0f6e66" stroke-width="3" stroke-linecap="round"/>
        <path d="M60 62v22M80 62v22M100 62v22" stroke="#cfe3df" stroke-width="3" stroke-linecap="round"/>
        <circle cx="122" cy="28" r="9" fill="#e9a820"/>
      </c:otherwise>
    </c:choose>
  </svg>
  <h2><c:out value="${titre}"/></h2>
  <c:if test="${not empty texte}"><p class="muted"><c:out value="${texte}"/></p></c:if>
  <div class="vide-actions"><jsp:doBody/></div>
</div>

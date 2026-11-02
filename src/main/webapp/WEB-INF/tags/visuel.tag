<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" description="Product picture: image if any, otherwise a gradient tied to the category" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ attribute name="produit" required="true" type="ma.fstt.entities.Produit" %>
<%@ attribute name="taille" required="false" description="sm or lg" %>
<div class="visuel ton-${produit.categorie.id % 6}${empty taille ? '' : ' '}${taille}">
  <c:choose>
    <c:when test="${not empty produit.imageUrl}">
      <img src="<c:out value='${produit.imageUrl}'/>" alt="" loading="lazy">
    </c:when>
    <c:otherwise>
      <span class="visuel-initiales" aria-hidden="true"><c:out value="${fn:toUpperCase(fn:substring(produit.nom, 0, 2))}"/></span>
      <span class="visuel-ref"><c:out value="${produit.reference}"/></span>
    </c:otherwise>
  </c:choose>
</div>

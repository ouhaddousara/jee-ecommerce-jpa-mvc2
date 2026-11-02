<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" description="Stock badge: available, last units, sold out" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ attribute name="stock" required="true" type="java.lang.Integer" %>
<c:choose>
  <c:when test="${stock <= 0}"><span class="stock stock-out">Épuisé</span></c:when>
  <c:when test="${stock <= 5}"><span class="stock stock-low">Dernières unités · <c:out value="${stock}"/></span></c:when>
  <c:otherwise><span class="stock stock-ok">En stock</span></c:otherwise>
</c:choose>

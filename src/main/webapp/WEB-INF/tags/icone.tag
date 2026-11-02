<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" description="Inline SVG icon (no external dependency)" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ attribute name="nom" required="true" %>
<svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="<c:choose>
<c:when test="${nom == 'vitrine'}">M3 9l1.5-5h15L21 9M3 9v11h18V9M3 9h18M9 20v-6h6v6</c:when>
<c:when test="${nom == 'panier'}">M6 7h12l1 13H5L6 7zM9 7a3 3 0 016 0</c:when>
<c:when test="${nom == 'utilisateur'}">M12 12a4 4 0 100-8 4 4 0 000 8zM4 21a8 8 0 0116 0</c:when>
<c:when test="${nom == 'produits'}">M3 7l9-4 9 4v10l-9 4-9-4V7zM3 7l9 4 9-4M12 11v10</c:when>
<c:when test="${nom == 'categories'}">M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z</c:when>
<c:when test="${nom == 'recherche'}">M11 19a8 8 0 100-16 8 8 0 000 16zM21 21l-4.3-4.3</c:when>
<c:when test="${nom == 'fermer'}">M6 6l12 12M18 6L6 18</c:when>
<c:when test="${nom == 'corbeille'}">M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3</c:when>
<c:when test="${nom == 'plus'}">M12 5v14M5 12h14</c:when>
<c:when test="${nom == 'menu'}">M4 6h16M4 12h16M4 18h16</c:when>
<c:when test="${nom == 'retour'}">M15 6l-6 6 6 6</c:when>
<c:otherwise>M5 12l5 5L20 7</c:otherwise>
</c:choose>"/></svg>

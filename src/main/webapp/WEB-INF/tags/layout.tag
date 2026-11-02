<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" description="Page layout: sidebar, flash message, mini-cart" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ attribute name="titre" required="true" description="Page title" %>
<%@ attribute name="nav" required="false" description="Active menu entry: vitrine, panier, produits, categories, connexion, inscription" %>
<fmt:setLocale value="fr_FR" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="user" value="${sessionScope.utilisateur}"/>
<c:set var="nbArticles" value="${empty sessionScope.panierCount ? 0 : sessionScope.panierCount}"/>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="csrf-token" content="<c:out value='${sessionScope.csrf}'/>">
  <meta name="ctx" content="<c:out value='${ctx}'/>">
  <title><c:out value="${titre}"/> · Atlas Boutique</title>
  <link rel="stylesheet" href="${ctx}/assets/css/app.css">
</head>
<body>
<a class="skip" href="#contenu">Aller au contenu</a>
<div class="app">

  <aside class="sidebar" id="sidebar">
    <a class="brand" href="${ctx}/vitrine">
      <span class="brand-mark"><t:icone nom="vitrine"/></span>
      <span class="brand-text">Atlas<small>Boutique</small></span>
    </a>

    <nav class="nav" aria-label="Navigation principale">
      <a class="nav-link${nav == 'vitrine' ? ' is-active' : ''}" href="${ctx}/vitrine">
        <t:icone nom="vitrine"/><span>Vitrine</span>
      </a>
      <c:if test="${user.client}">
        <a class="nav-link js-open-cart${nav == 'panier' ? ' is-active' : ''}" href="${ctx}/panier">
          <t:icone nom="panier"/><span>Panier</span>
          <span class="badge js-cart-count${nbArticles == 0 ? ' is-empty' : ''}"><c:out value="${nbArticles}"/></span>
        </a>
      </c:if>
      <c:if test="${user.admin}">
        <p class="nav-section">Administration</p>
        <a class="nav-link${nav == 'produits' ? ' is-active' : ''}" href="${ctx}/admin/produits">
          <t:icone nom="produits"/><span>Produits</span>
        </a>
        <a class="nav-link${nav == 'categories' ? ' is-active' : ''}" href="${ctx}/admin/categories">
          <t:icone nom="categories"/><span>Catégories</span>
        </a>
      </c:if>
    </nav>

    <div class="sidebar-foot">
      <c:choose>
        <c:when test="${not empty user}">
          <div class="user">
            <span class="user-avatar"><t:icone nom="utilisateur"/></span>
            <span class="user-info">
              <strong><c:out value="${user.nomComplet}"/></strong>
              <small><c:out value="${user.admin ? 'Administrateur' : 'Client'}"/></small>
            </span>
          </div>
          <form method="post" action="${ctx}/client">
            <input type="hidden" name="action" value="deconnexion">
            <t:csrf/>
            <button type="submit" class="btn btn-side btn-block">Se déconnecter</button>
          </form>
        </c:when>
        <c:otherwise>
          <a class="btn btn-accent btn-block" href="${ctx}/client?action=connexion">Se connecter</a>
          <a class="btn btn-side btn-block" href="${ctx}/client?action=inscription">Créer un compte</a>
        </c:otherwise>
      </c:choose>
    </div>
  </aside>

  <div class="main">
    <header class="topbar">
      <button type="button" class="icon-btn js-menu" aria-label="Ouvrir le menu" aria-controls="sidebar">
        <t:icone nom="menu"/>
      </button>
      <a class="topbar-brand" href="${ctx}/vitrine">Atlas Boutique</a>
      <c:if test="${user.client}">
        <a class="icon-btn js-open-cart topbar-cart" href="${ctx}/panier" aria-label="Panier">
          <t:icone nom="panier"/>
          <span class="badge js-cart-count${nbArticles == 0 ? ' is-empty' : ''}"><c:out value="${nbArticles}"/></span>
        </a>
      </c:if>
    </header>

    <main class="content" id="contenu">
      <c:if test="${not empty flash}">
        <div class="flash flash-${flash.type}" role="status"><c:out value="${flash.texte}"/></div>
      </c:if>
      <jsp:doBody/>
    </main>

    <footer class="footer">
      <span>Atelier JEE 2 · MVC2 et JPA · FST Tanger</span>
    </footer>
  </div>
</div>
<div class="scrim js-menu-close"></div>

<c:if test="${user.client}">
  <div class="drawer-overlay js-drawer-close"></div>
  <aside class="drawer" id="drawer" aria-hidden="true" aria-label="Mini-panier">
    <header class="drawer-head">
      <h2>Mon panier</h2>
      <button type="button" class="icon-btn js-drawer-close" aria-label="Fermer le panier"><t:icone nom="fermer"/></button>
    </header>
    <div class="drawer-body js-drawer-body"></div>
    <footer class="drawer-foot">
      <div class="drawer-total"><span>Total</span><strong class="js-drawer-total">0,00 MAD</strong></div>
      <a class="btn btn-primary btn-block" href="${ctx}/panier">Voir le panier</a>
    </footer>
  </aside>
</c:if>

<div class="toasts js-toasts" aria-live="polite"></div>

<script src="${ctx}/assets/js/vendor/jquery-3.7.1.min.js"></script>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>

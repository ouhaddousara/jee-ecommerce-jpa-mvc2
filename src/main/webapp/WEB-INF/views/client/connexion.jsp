<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<t:layout titre="Connexion" nav="connexion">

<section class="auth">
  <div class="auth-carte">
    <h1>Connexion</h1>
    <p class="muted">Content de te revoir. Connecte-toi pour retrouver ton panier.</p>

    <c:if test="${not empty erreur}">
      <p class="alerte alerte-erreur" role="alert"><c:out value="${erreur}"/></p>
    </c:if>

    <form method="post" action="${ctx}/client" novalidate>
      <input type="hidden" name="action" value="connexion">
      <t:csrf/>
      <t:champ nom="email" libelle="Adresse e-mail" type="email" valeur="${email}"
               requis="true" autocomplete="username" maxlength="150"/>
      <t:champ nom="motDePasse" libelle="Mot de passe" type="password"
               requis="true" autocomplete="current-password" maxlength="100"/>
      <button type="submit" class="btn btn-primary btn-block btn-lg">Se connecter</button>
    </form>

    <p class="auth-pied">Pas encore de compte ?
      <a href="${ctx}/client?action=inscription">Créer un compte</a></p>
  </div>
</section>

</t:layout>

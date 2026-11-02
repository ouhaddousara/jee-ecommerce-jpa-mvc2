<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<t:layout titre="Créer un compte" nav="inscription">

<section class="auth">
  <div class="auth-carte auth-large">
    <h1>Créer un compte</h1>
    <p class="muted">Quelques informations suffisent. Ton panier est créé avec ton compte.</p>

    <c:if test="${not empty erreurs}">
      <p class="alerte alerte-erreur" role="alert">Le formulaire contient des erreurs : corrige les champs signalés.</p>
    </c:if>

    <form method="post" action="${ctx}/client" novalidate>
      <input type="hidden" name="action" value="inscription">
      <t:csrf/>
      <div class="deux-col">
        <t:champ nom="prenom" libelle="Prénom" valeur="${form.prenom}" erreurs="${erreurs}"
                 requis="true" autocomplete="given-name" maxlength="80"/>
        <t:champ nom="nom" libelle="Nom" valeur="${form.nom}" erreurs="${erreurs}"
                 requis="true" autocomplete="family-name" maxlength="80"/>
      </div>
      <t:champ nom="email" libelle="Adresse e-mail" type="email" valeur="${form.email}" erreurs="${erreurs}"
               requis="true" autocomplete="email" maxlength="150"/>
      <div class="deux-col">
        <t:champ nom="motDePasse" libelle="Mot de passe" type="password" erreurs="${erreurs}"
                 requis="true" autocomplete="new-password" maxlength="100"
                 aide="8 caractères minimum, avec au moins une lettre et un chiffre."/>
        <t:champ nom="confirmation" libelle="Confirmation" type="password" erreurs="${erreurs}"
                 requis="true" autocomplete="new-password" maxlength="100"/>
      </div>
      <t:champ nom="adresse" libelle="Adresse de livraison" valeur="${form.adresse}" erreurs="${erreurs}"
               autocomplete="street-address" maxlength="255" aide="Facultatif."/>
      <t:champ nom="telephone" libelle="Téléphone" type="tel" valeur="${form.telephone}" erreurs="${erreurs}"
               autocomplete="tel" maxlength="30" aide="Facultatif, par exemple +212 6 12 34 56 78."/>
      <button type="submit" class="btn btn-primary btn-block btn-lg">Créer mon compte</button>
    </form>

    <p class="auth-pied">Déjà inscrit ?
      <a href="${ctx}/client?action=connexion">Se connecter</a></p>
  </div>
</section>

</t:layout>

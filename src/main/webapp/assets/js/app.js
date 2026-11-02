/*
 * Atlas Boutique front-end behaviour (jQuery, served locally).
 *
 * - AJAX add-to-cart on every form.js-add, with a mini-cart drawer
 * - +/- and remove buttons inside the drawer
 * - confirmation on [data-confirm], mobile menu, toasts, flash auto-hide
 *
 * All text coming from the server is inserted with .text(), never as HTML,
 * so the CSP (no inline script) and output escaping stay consistent.
 * Every page keeps working without this script: the forms post normally
 * and the server answers with a redirect.
 */
(function ($) {
  'use strict';

  var ctx = $('meta[name="ctx"]').attr('content') || '';
  var csrf = $('meta[name="csrf-token"]').attr('content') || '';
  var $drawer = $('#drawer');
  var $overlay = $('.drawer-overlay');
  var $body = $('.js-drawer-body');
  var lastFocus = null;

  // ---------- Toasts ----------
  function toast(message, error) {
    if (!message) { return; }
    var $t = $('<div class="toast" role="status"></div>').text(message).toggleClass('toast-error', !!error);
    $('.js-toasts').append($t);
    setTimeout(function () {
      $t.addClass('is-leaving');
      setTimeout(function () { $t.remove(); }, 350);
    }, 3200);
  }

  // ---------- Drawer ----------
  function openDrawer() {
    if (!$drawer.length) { return; }
    lastFocus = document.activeElement;
    $drawer.addClass('is-open').attr('aria-hidden', 'false');
    $overlay.addClass('is-open');
    $drawer.find('.js-drawer-close').first().trigger('focus');
  }

  function closeDrawer() {
    $drawer.removeClass('is-open').attr('aria-hidden', 'true');
    $overlay.removeClass('is-open');
    if (lastFocus) { $(lastFocus).trigger('focus'); }
  }

  function visuel(ligne) {
    var $v = $('<div class="visuel"></div>').addClass('ton-' + ligne.ton);
    $('<span class="visuel-initiales" aria-hidden="true"></span>')
      .text(String(ligne.nom).substring(0, 2).toUpperCase()).appendTo($v);
    return $v;
  }

  function button(label, aria, action, ligne, disabled) {
    return $('<button type="button"></button>')
      .text(label).attr('aria-label', aria)
      .attr('data-act', action).attr('data-id', ligne.produitId).attr('data-qte', ligne.quantite)
      .prop('disabled', !!disabled);
  }

  function render(panier) {
    $('.js-cart-count').text(panier.nombreArticles).toggleClass('is-empty', panier.nombreArticles === 0);
    $('.js-drawer-total').text(panier.total);
    $body.empty();
    if (!panier.lignes || panier.lignes.length === 0) {
      $body.append($('<p class="mini-vide"></p>').text('Ton panier est vide.'));
      return;
    }
    $.each(panier.lignes, function (_, l) {
      var $row = $('<div class="mini"></div>');
      $row.append(visuel(l));

      var $info = $('<div></div>');
      $info.append($('<div class="mini-nom"></div>').text(l.nom));
      $info.append($('<div class="mini-ref"></div>').text(l.reference + ' · ' + l.prixUnitaire));
      var $ctl = $('<div class="mini-controles"></div>');
      $ctl.append(button('−', 'Diminuer la quantité de ' + l.nom, 'moins', l, l.quantite <= 1));
      $ctl.append($('<span class="mini-qte"></span>').text(l.quantite));
      $ctl.append(button('+', 'Augmenter la quantité de ' + l.nom, 'plus', l, l.quantite >= l.stock || l.quantite >= 99));
      $info.append($ctl);
      $row.append($info);

      var $right = $('<div class="mini-droite"></div>');
      $right.append($('<span></span>').text(l.sousTotal));
      $right.append(button('Retirer', 'Retirer ' + l.nom + ' du panier', 'retirer', l, false)
        .addClass('btn btn-danger btn-sm'));
      $row.append($right);
      $body.append($row);
    });
  }

  // ---------- Server calls ----------
  function post(data) {
    data._csrf = csrf;
    return $.ajax({
      url: ctx + '/panier',
      method: 'POST',
      data: data,
      dataType: 'json',
      headers: { 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': csrf }
    });
  }

  function failed(xhr) {
    var json = xhr.responseJSON;
    if (xhr.status === 401 || (json && json.connexion)) {
      window.location.href = (json && json.connexion) || (ctx + '/client?action=connexion');
      return;
    }
    toast((json && json.message) || 'Une erreur est survenue. Réessaie dans un instant.', true);
  }

  function refresh() {
    return $.ajax({
      url: ctx + '/panier', method: 'GET', dataType: 'json',
      data: { action: 'resume' }, headers: { 'X-Requested-With': 'XMLHttpRequest' }
    }).done(render).fail(failed);
  }

  // ---------- Events ----------
  $(document).on('submit', 'form.js-add', function (e) {
    var $form = $(this);
    if (!window.JSON || !$.ajax) { return; }          // fall back to a normal post
    e.preventDefault();
    var $btn = $form.find('button[type="submit"]');
    $btn.prop('disabled', true);
    post({
      action: 'ajouter',
      produitId: $form.find('[name="produitId"]').val(),
      quantite: $form.find('[name="quantite"]').val() || 1
    }).done(function (panier) {
      render(panier);
      toast(panier.message || 'Produit ajouté au panier.');
      openDrawer();
    }).fail(failed).always(function () { $btn.prop('disabled', false); });
  });

  $(document).on('click', '.js-open-cart', function (e) {
    if (!$drawer.length || $(this).closest('.panier-grille').length) { return; }
    if (window.location.pathname === ctx + '/panier') { return; }   // already on the cart page
    e.preventDefault();
    refresh().done(openDrawer);
  });

  $(document).on('click', '.js-drawer-close', closeDrawer);
  $(document).on('keydown', function (e) {
    if (e.key === 'Escape') {
      closeDrawer();
      $('body').removeClass('menu-open');
      $('.scrim').removeClass('is-open');
    }
  });

  $body.on('click', 'button[data-act]', function () {
    var $b = $(this);
    var id = $b.attr('data-id');
    var qte = parseInt($b.attr('data-qte'), 10);
    var act = $b.attr('data-act');
    var req;
    $body.addClass('is-loading');
    if (act === 'retirer') {
      req = post({ action: 'retirer', produitId: id });
    } else {
      req = post({ action: 'modifier', produitId: id, quantite: act === 'plus' ? qte + 1 : qte - 1 });
    }
    req.done(function (panier) {
      render(panier);
      if (panier.message) { toast(panier.message); }
    }).fail(failed).always(function () { $body.removeClass('is-loading'); });
  });

  $(document).on('submit', 'form', function (e) {
    var message = $(this).find('[data-confirm]').attr('data-confirm');
    if (message && !window.confirm(message)) { e.preventDefault(); }
  });

  // Mobile menu
  $(document).on('click', '.js-menu', function () {
    $('body').addClass('menu-open');
    $('.scrim').addClass('is-open');
  });
  $(document).on('click', '.js-menu-close', function () {
    $('body').removeClass('menu-open');
    $('.scrim').removeClass('is-open');
  });

  // Server flash message disappears by itself, except errors
  $('.flash-success, .flash-info').delay(5000).fadeOut(400);
}(jQuery));

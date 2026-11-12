/* Funciones de la web: buscador y filtros de la portada, mapa, y botones de las fichas
   (copiar cita, imprimir). generar-web.ps1 lo copia a docs/web.js. */
(function () {
  'use strict';

  /* Quita acentos, puntos de letra dudosa y signos de Leiden para que "Mitrhae" encuentre "Mitrh(a)ẹ[- - -]" */
  function normalizar(s) {
    return (s || '').normalize('NFD').replace(/[̀-ͯ]/g, '')
      .replace(/[\[\]()<>{}⟦⟧]/g, '').replace(/-\s(-\s)*-/g, ' ').toLowerCase()
      .replace(/[α-ω]/g, function (c) { return GRIEGO[c] || c; });
  }
  /* Transcripción sencilla del griego, para que "Eutyches" encuentre "Eutyχηs" */
  var GRIEGO = { 'α': 'a', 'β': 'b', 'γ': 'g', 'δ': 'd', 'ε': 'e', 'ζ': 'z', 'η': 'e', 'θ': 'th', 'ι': 'i',
    'κ': 'c', 'λ': 'l', 'μ': 'm', 'ν': 'n', 'ξ': 'x', 'ο': 'o', 'π': 'p', 'ρ': 'r', 'σ': 's', 'ς': 's',
    'τ': 't', 'υ': 'y', 'φ': 'ph', 'χ': 'ch', 'ψ': 'ps', 'ω': 'o' };

  /* ---------- Portada: buscador y filtros ---------- */
  var lista = document.getElementById('lista');
  if (lista) {
    var items = Array.prototype.slice.call(lista.children);
    var total = items.length;
    var campoTexto = document.getElementById('buscar');
    var filtros = {
      yac: document.getElementById('f-yac'),
      tipo: document.getElementById('f-tipo'),
      soporte: document.getElementById('f-soporte'),
      siglo: document.getElementById('f-siglo')
    };
    var recuento = document.getElementById('recuento');
    var vacio = document.getElementById('sin-resultados');
    var limpiar = document.getElementById('limpiar');

    items.forEach(function (li) {
      li._texto = normalizar(li.textContent + ' ' + li.getAttribute('data-buscar'));
    });

    function aplicar() {
      var palabras = normalizar(campoTexto.value).split(/\s+/).filter(Boolean);
      var yac = filtros.yac.value, tipo = filtros.tipo.value,
          soporte = filtros.soporte.value, siglo = filtros.siglo.value;
      var n = 0;
      items.forEach(function (li) {
        var ok = (!yac || li.getAttribute('data-yac') === yac) &&
                 (!tipo || li.getAttribute('data-tipo') === tipo) &&
                 (!soporte || li.getAttribute('data-soporte') === soporte) &&
                 (!siglo || (' ' + li.getAttribute('data-siglos') + ' ').indexOf(' ' + siglo + ' ') !== -1) &&
                 palabras.every(function (p) { return li._texto.indexOf(p) !== -1; });
        li.hidden = !ok;
        if (ok) n++;
      });
      var activo = palabras.length || yac || tipo || soporte || siglo;
      recuento.textContent = activo
        ? 'Mostrando ' + n + ' de ' + total + ' grafitos'
        : total + ' grafitos';
      vacio.hidden = n !== 0;
      limpiar.hidden = !activo;

      /* Guarda la búsqueda en la dirección de la página, para poder enlazarla */
      var q = new URLSearchParams();
      if (campoTexto.value.trim()) q.set('q', campoTexto.value.trim());
      if (yac) q.set('yac', yac);
      if (tipo) q.set('tipo', tipo);
      if (soporte) q.set('soporte', soporte);
      if (siglo) q.set('siglo', siglo);
      var nueva = location.pathname + (q.toString() ? '?' + q.toString() : '') + location.hash;
      try { history.replaceState(null, '', nueva); } catch (e) { /* sin historial */ }
    }

    /* Lee la búsqueda de la dirección (p. ej. index.html?yac=Cara) */
    var inicial = new URLSearchParams(location.search);
    campoTexto.value = inicial.get('q') || '';
    Object.keys(filtros).forEach(function (k) {
      var v = inicial.get(k);
      if (v && filtros[k].querySelector('option[value="' + v.replace(/"/g, '') + '"]')) filtros[k].value = v;
      filtros[k].addEventListener('change', aplicar);
    });
    campoTexto.addEventListener('input', aplicar);
    limpiar.addEventListener('click', function () {
      campoTexto.value = '';
      Object.keys(filtros).forEach(function (k) { filtros[k].value = ''; });
      aplicar();
      campoTexto.focus();
    });
    aplicar();

    /* Ver los grafitos de un yacimiento sin recargar la página */
    window.verYacimiento = function (clave) {
      filtros.yac.value = clave;
      aplicar();
      document.getElementById('corpus').scrollIntoView({ behavior: 'smooth' });
    };
    Array.prototype.forEach.call(document.querySelectorAll('.ver-yac'), function (a) {
      a.addEventListener('click', function (ev) {
        ev.preventDefault();
        window.verYacimiento(a.parentNode.getAttribute('data-clave'));
      });
    });
  }

  /* ---------- Portada: mapa ---------- */
  var lienzo = document.getElementById('mapa-lienzo');
  if (lienzo && window.L) {
    var sitios = Array.prototype.map.call(document.querySelectorAll('.yacimientos li'), function (li) {
      return {
        clave: li.getAttribute('data-clave'),
        nombre: li.getAttribute('data-nombre'),
        n: parseInt(li.getAttribute('data-n'), 10) || 0,
        lat: parseFloat(li.getAttribute('data-lat')),
        lon: parseFloat(li.getAttribute('data-lon'))
      };
    }).filter(function (s) { return !isNaN(s.lat) && !isNaN(s.lon); });

    var mapa = L.map(lienzo, { scrollWheelZoom: false });
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 18,
      attribution: '&copy; colaboradores de <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(mapa);

    var color = getComputedStyle(document.documentElement).getPropertyValue('--acento').trim() || '#8a3b1f';
    var limites = [];
    sitios.forEach(function (s) {
      var punto = L.circleMarker([s.lat, s.lon], {
        radius: 7 + Math.sqrt(s.n) * 2,
        color: color, weight: 2, fillColor: color, fillOpacity: 0.55
      }).addTo(mapa);
      var caja = document.createElement('div');
      caja.className = 'globo';
      var t = document.createElement('strong'); t.textContent = s.clave; caja.appendChild(t);
      var m = document.createElement('div'); m.textContent = s.nombre; caja.appendChild(m);
      var b = document.createElement('a');
      b.href = 'index.html?yac=' + encodeURIComponent(s.clave) + '#corpus';
      b.textContent = 'Ver ' + s.n + (s.n === 1 ? ' grafito' : ' grafitos');
      b.addEventListener('click', function (ev) {
        if (window.verYacimiento) { ev.preventDefault(); mapa.closePopup(); window.verYacimiento(s.clave); }
      });
      caja.appendChild(b);
      punto.bindPopup(caja);
      punto.bindTooltip(s.clave + ' (' + s.n + ')');
      limites.push([s.lat, s.lon]);
    });
    if (limites.length > 1) mapa.fitBounds(limites, { padding: [60, 60], maxZoom: 9 });
    else if (limites.length === 1) mapa.setView(limites[0], 9);
    else mapa.setView([42.5, -2.5], 6);
  }

  /* ---------- Ficha: copiar la cita ---------- */
  var cita = document.getElementById('cita');
  if (cita) {
    var fecha = document.getElementById('cita-fecha');
    if (fecha) {
      var hoy = new Date();
      fecha.textContent = ' (consulta: ' + ('0' + hoy.getDate()).slice(-2) + '/' +
        ('0' + (hoy.getMonth() + 1)).slice(-2) + '/' + hoy.getFullYear() + ')';
    }
    var copiar = document.getElementById('copiar-cita');
    if (copiar) {
      copiar.hidden = false;
      copiar.addEventListener('click', function () {
        var texto = cita.textContent.replace(/\s+/g, ' ').trim();
        var listo = function () {
          var antes = copiar.textContent;
          copiar.textContent = 'Cita copiada';
          setTimeout(function () { copiar.textContent = antes; }, 2000);
        };
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(texto).then(listo, function () { seleccionar(cita); });
        } else {
          seleccionar(cita);
        }
      });
    }
  }
  function seleccionar(el) {
    var r = document.createRange(); r.selectNodeContents(el);
    var s = window.getSelection(); s.removeAllRanges(); s.addRange(r);
  }

  /* ---------- Ficha: imprimir ---------- */
  var imprimir = document.getElementById('imprimir');
  if (imprimir) {
    imprimir.hidden = false;
    imprimir.addEventListener('click', function () { window.print(); });
  }
})();

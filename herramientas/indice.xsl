<?xml version="1.0" encoding="UTF-8"?>
<!-- Crea la portada de la web: presentación, cifras, mapa, buscador con filtros y lista de grafitos.
     Recibe un <corpus> preparado por generar-web.ps1: datos de los yacimientos, opciones de los filtros
     y una <entrada> por grafito con su ficha EpiDoc dentro. -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <xsl:include href="leiden.xsl"/>
  <xsl:include href="comun.xsl"/>
  <xsl:output method="html" indent="no" encoding="UTF-8"/>
  <xsl:param name="repo"/>

  <xsl:template match="/">
    <xsl:variable name="c" select="/corpus"/>
    <html lang="es">
      <head>
        <xsl:call-template name="head">
          <xsl:with-param name="titulo">Grafitos sobre cerámica romana · Corpus EpiDoc</xsl:with-param>
          <xsl:with-param name="descripcion">Edición digital (EpiDoc) de los grafitos sobre cerámica romana publicados por Pablo Ozcáriz Gil.</xsl:with-param>
          <xsl:with-param name="mapa" select="true()"/>
        </xsl:call-template>
      </head>
      <body class="portada">
        <xsl:call-template name="cabecera">
          <xsl:with-param name="activa">corpus</xsl:with-param>
        </xsl:call-template>

        <main class="ancho">
          <section class="presentacion">
            <h1>Grafitos sobre cerámica romana</h1>
            <p class="sub">Corpus EpiDoc de los grafitos publicados por Pablo Ozcáriz Gil (Universidad Rey Juan Carlos)</p>
            <p class="intro">
              <xsl:text>Edición digital de grafitos sobre cerámica de época romana. Cada ficha incluye la transcripción
                según el sistema de Leiden, la descripción del soporte, el comentario y la bibliografía, y puede
                descargarse en formato EpiDoc (XML). Los signos de edición se explican en </xsl:text>
              <a href="criterios.html">Criterios de edición</a>
              <xsl:text>.</xsl:text>
            </p>
            <dl class="cifras">
              <div><dt>Grafitos</dt><dd><xsl:value-of select="$c/@grafitos"/></dd></div>
              <div><dt>Yacimientos</dt><dd><xsl:value-of select="$c/@yacimientos"/></dd></div>
              <div><dt>Publicaciones</dt><dd><xsl:value-of select="$c/@publicaciones"/></dd></div>
            </dl>
          </section>

          <section id="mapa" class="bloque-mapa">
            <h2>Mapa de yacimientos</h2>
            <div id="mapa-lienzo" class="mapa-lienzo" role="region" aria-label="Mapa de yacimientos"></div>
            <ul class="yacimientos">
              <xsl:for-each select="$c/yacimiento">
                <xsl:sort select="@clave"/>
                <li data-clave="{@clave}" data-lat="{@lat}" data-lon="{@lon}" data-n="{@n}" data-nombre="{@nombre}">
                  <a href="index.html?yac={@clave}#corpus" class="ver-yac">
                    <span class="yac-antiguo"><xsl:value-of select="@clave"/></span>
                    <span class="yac-actual"><xsl:value-of select="@nombre"/></span>
                    <span class="yac-n">
                      <xsl:value-of select="@n"/>
                      <xsl:choose>
                        <xsl:when test="@n = 1"> grafito</xsl:when>
                        <xsl:otherwise> grafitos</xsl:otherwise>
                      </xsl:choose>
                    </span>
                  </a>
                </li>
              </xsl:for-each>
            </ul>
            <p class="nota-mapa">Situación aproximada de cada yacimiento.</p>
          </section>

          <section id="corpus" class="bloque-corpus">
            <h2>Corpus</h2>
            <form class="buscador" role="search" onsubmit="return false">
              <label class="campo campo-texto">
                <span>Buscar</span>
                <input type="search" id="buscar" placeholder="Martii, palma, Hisp. 37, Mitra…" autocomplete="off"/>
              </label>
              <xsl:call-template name="filtro">
                <xsl:with-param name="id">f-yac</xsl:with-param>
                <xsl:with-param name="etiqueta">Yacimiento</xsl:with-param>
                <xsl:with-param name="grupo">yac</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="filtro">
                <xsl:with-param name="id">f-tipo</xsl:with-param>
                <xsl:with-param name="etiqueta">Tipo</xsl:with-param>
                <xsl:with-param name="grupo">tipo</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="filtro">
                <xsl:with-param name="id">f-soporte</xsl:with-param>
                <xsl:with-param name="etiqueta">Soporte</xsl:with-param>
                <xsl:with-param name="grupo">soporte</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="filtro">
                <xsl:with-param name="id">f-siglo</xsl:with-param>
                <xsl:with-param name="etiqueta">Siglo</xsl:with-param>
                <xsl:with-param name="grupo">siglo</xsl:with-param>
              </xsl:call-template>
            </form>
            <p class="recuento" id="recuento" aria-live="polite">
              <xsl:value-of select="$c/@grafitos"/>
              <xsl:text> grafitos</xsl:text>
            </p>
            <button type="button" class="boton-suave" id="limpiar" hidden="hidden">Quitar filtros</button>

            <ol class="lista" id="lista">
              <xsl:for-each select="$c/entrada">
                <xsl:sort select="@id"/>
                <xsl:variable name="t" select="tei:TEI"/>
                <li data-yac="{@yac}" data-tipo="{@tipo}" data-soporte="{@soporte}" data-siglos="{@siglos}"
                    data-buscar="{normalize-space(concat($t//tei:titleStmt/tei:title, ' ', @soporte-texto, ' ', @yac, ' ', @lugar, ' ', @palabras))}">
                  <a href="{@id}.html">
                    <span class="lectura" lang="la">
                      <xsl:for-each select="$t/tei:text/tei:body/tei:div[@type='edition']//tei:ab/node()">
                        <xsl:choose>
                          <xsl:when test="self::tei:lb and preceding-sibling::tei:lb"> / </xsl:when>
                          <xsl:when test="self::tei:lb"/>
                          <xsl:otherwise><xsl:apply-templates select="." mode="leiden"/></xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </span>
                    <span class="meta">
                      <xsl:value-of select="@yac"/>
                      <xsl:if test="normalize-space(@soporte-texto) != ''">
                        <xsl:text> · </xsl:text><xsl:value-of select="@soporte-texto"/>
                      </xsl:if>
                      <xsl:if test="normalize-space(@datacion) != ''">
                        <xsl:text> · </xsl:text><xsl:value-of select="@datacion"/>
                      </xsl:if>
                    </span>
                    <span class="id"><xsl:value-of select="@id"/></span>
                  </a>
                </li>
              </xsl:for-each>
            </ol>
            <p class="sin-resultados" id="sin-resultados" hidden="hidden">Ningún grafito coincide con la búsqueda. Prueba con menos filtros.</p>
          </section>

          <section class="descargas">
            <h2>Datos abiertos</h2>
            <p>
              <xsl:text>Todas las fichas pueden descargarse en EpiDoc (XML) desde cada página o desde el </xsl:text>
              <a href="{$repo}">repositorio en GitHub</a>
              <xsl:text>, donde también está el </xsl:text>
              <a href="{$repo}/blob/main/catalogo.csv">catálogo en formato CSV</a>
              <xsl:text> (se abre con Excel).</xsl:text>
            </p>
          </section>
        </main>

        <xsl:call-template name="pie">
          <xsl:with-param name="repo" select="$repo"/>
        </xsl:call-template>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
        <script src="web.js"></script>
      </body>
    </html>
  </xsl:template>

  <!-- Desplegable de un filtro; las opciones las prepara generar-web.ps1 -->
  <xsl:template name="filtro">
    <xsl:param name="id"/>
    <xsl:param name="etiqueta"/>
    <xsl:param name="grupo"/>
    <label class="campo">
      <span><xsl:value-of select="$etiqueta"/></span>
      <select id="{$id}">
        <option value="">Todos</option>
        <xsl:for-each select="/corpus/opcion[@grupo = $grupo]">
          <option value="{@valor}"><xsl:value-of select="@texto"/></option>
        </xsl:for-each>
      </select>
    </label>
  </xsl:template>
</xsl:stylesheet>

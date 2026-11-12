<?xml version="1.0" encoding="UTF-8"?>
<!-- Partes comunes a todas las páginas: cabecera con el menú, pie y cabecera HTML (head). -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <xsl:variable name="web" select="'https://pozcariz.github.io/grafitos-epidoc/'"/>
  <xsl:variable name="nombre-corpus" select="'Grafitos sobre cerámica romana: corpus EpiDoc'"/>

  <!-- Contenido del <head> -->
  <xsl:template name="head">
    <xsl:param name="titulo"/>
    <xsl:param name="descripcion"/>
    <xsl:param name="mapa" select="false()"/>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title><xsl:value-of select="$titulo"/></title>
    <meta name="description" content="{$descripcion}"/>
    <meta name="author" content="Pablo Ozcáriz Gil"/>
    <xsl:if test="$mapa">
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css"/>
    </xsl:if>
    <link rel="stylesheet" href="estilo.css"/>
  </xsl:template>

  <!-- Barra superior con el nombre del corpus y el menú -->
  <xsl:template name="cabecera">
    <xsl:param name="activa"/>
    <header class="barra">
      <div class="barra-dentro">
        <a class="marca" href="index.html">Grafitos sobre cerámica romana</a>
        <nav class="menu" aria-label="Menú principal">
          <a href="index.html#corpus">
            <xsl:if test="$activa = 'corpus'"><xsl:attribute name="aria-current">page</xsl:attribute></xsl:if>
            <xsl:text>Corpus</xsl:text>
          </a>
          <a href="index.html#mapa">Mapa</a>
          <a href="criterios.html">
            <xsl:if test="$activa = 'criterios'"><xsl:attribute name="aria-current">page</xsl:attribute></xsl:if>
            <xsl:text>Criterios de edición</xsl:text>
          </a>
          <a href="citar.html">
            <xsl:if test="$activa = 'citar'"><xsl:attribute name="aria-current">page</xsl:attribute></xsl:if>
            <xsl:text>Cómo citar</xsl:text>
          </a>
        </nav>
      </div>
    </header>
  </xsl:template>

  <!-- Pie de página -->
  <xsl:template name="pie">
    <xsl:param name="repo"/>
    <footer class="pie">
      <p>
        <xsl:text>Edición: Pablo Ozcáriz Gil (Universidad Rey Juan Carlos). Codificación según las </xsl:text>
        <a href="https://epidoc.stoa.org/">EpiDoc Guidelines</a>
        <xsl:text>.</xsl:text>
      </p>
      <p>
        <xsl:text>Licencia </xsl:text>
        <a href="https://creativecommons.org/licenses/by/4.0/deed.es">CC BY 4.0</a>
        <xsl:text> · </xsl:text>
        <a href="{$repo}">Repositorio en GitHub</a>
        <xsl:text> · </xsl:text>
        <a href="citar.html">Cómo citar</a>
      </p>
    </footer>
  </xsl:template>
</xsl:stylesheet>

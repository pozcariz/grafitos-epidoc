<?xml version="1.0" encoding="UTF-8"?>
<!-- Crea la portada de la web con la lista de todos los grafitos.
     Recibe un <corpus> con todas las fichas EpiDoc dentro (lo prepara generar-web.ps1). -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <xsl:include href="leiden.xsl"/>
  <xsl:output method="xml" omit-xml-declaration="yes" indent="no" encoding="UTF-8"/>
  <xsl:param name="repo"/>

  <xsl:template match="/">
    <html lang="es">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Grafitos sobre cerámica romana</title>
        <link rel="stylesheet" href="estilo.css"/>
      </head>
      <body>
        <main>
          <h1>Grafitos sobre cerámica romana</h1>
          <p class="sub">Corpus EpiDoc de los grafitos publicados por Pablo Ozcáriz Gil (Universidad Rey Juan Carlos)</p>
          <p class="intro">
            <xsl:text>Edición digital de </xsl:text>
            <xsl:value-of select="count(/corpus/tei:TEI)"/>
            <xsl:choose>
              <xsl:when test="count(/corpus/tei:TEI) = 1"> grafito</xsl:when>
              <xsl:otherwise> grafitos</xsl:otherwise>
            </xsl:choose>
            <xsl:text>. Cada ficha incluye la transcripción según el sistema de Leiden, la descripción del soporte,
              el comentario y la bibliografía, y puede descargarse en formato EpiDoc (XML).</xsl:text>
          </p>
          <ol class="lista">
            <xsl:for-each select="/corpus/tei:TEI">
              <xsl:sort select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='filename']"/>
              <xsl:variable name="id" select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='filename']"/>
              <li>
                <a href="{$id}.html">
                  <span class="lectura" lang="la">
                    <xsl:for-each select="tei:text/tei:body/tei:div[@type='edition']//tei:ab/node()">
                      <xsl:choose>
                        <xsl:when test="self::tei:lb and preceding-sibling::tei:lb"> / </xsl:when>
                        <xsl:when test="self::tei:lb"/>
                        <xsl:otherwise><xsl:apply-templates select="." mode="leiden"/></xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                  </span>
                  <span class="lugar">
                    <xsl:value-of select="normalize-space(tei:teiHeader//tei:origin/tei:origPlace)"/>
                    <xsl:text> · </xsl:text>
                    <xsl:value-of select="normalize-space(tei:teiHeader//tei:origin/tei:origDate)"/>
                  </span>
                  <span class="id"><xsl:value-of select="$id"/></span>
                </a>
              </li>
            </xsl:for-each>
          </ol>
        </main>
        <footer class="pie">
          <p><a href="{$repo}">Repositorio en GitHub</a> (descarga de las fichas EpiDoc)</p>
          <p>Licencia <a href="https://creativecommons.org/licenses/by/4.0/deed.es">CC BY 4.0</a>.</p>
        </footer>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!--
  Plantillas comunes: convierten el texto EpiDoc en una transcripción según el sistema de Leiden.
  Las usan ficha.xsl e indice.xsl.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <!-- Espacios: los saltos de línea del XML no cuentan; un espacio entre palabras sí -->
  <xsl:template match="text()" mode="leiden">
    <xsl:choose>
      <xsl:when test="normalize-space(.) = '' and contains(., '&#10;')"/>
      <xsl:when test="normalize-space(.) = ''"><xsl:text> </xsl:text></xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Cambio de línea -->
  <xsl:template match="tei:lb" mode="leiden">
    <xsl:if test="preceding::tei:lb[ancestor::tei:div[@type='edition']] and not(ancestor::tei:rdg)">
      <br/>
    </xsl:if>
    <xsl:if test="not(ancestor::tei:rdg)">
      <span class="ln"><xsl:value-of select="@n"/></span>
    </xsl:if>
  </xsl:template>

  <!-- Abreviaturas: a(bc) -->
  <xsl:template match="tei:expan | tei:abbr | tei:w | tei:hi | tei:seg" mode="leiden">
    <xsl:apply-templates mode="leiden"/>
  </xsl:template>
  <xsl:template match="tei:ex" mode="leiden">
    <xsl:text>(</xsl:text><xsl:apply-templates mode="leiden"/><xsl:text>)</xsl:text>
  </xsl:template>

  <!-- Letras dudosas: punto debajo -->
  <xsl:template match="tei:unclear" mode="leiden">
    <xsl:call-template name="punto-debajo">
      <xsl:with-param name="s" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="punto-debajo">
    <xsl:param name="s"/>
    <xsl:if test="string-length($s) &gt; 0">
      <xsl:value-of select="substring($s, 1, 1)"/>
      <xsl:if test="normalize-space(substring($s, 1, 1)) != ''"><xsl:text>&#x0323;</xsl:text></xsl:if>
      <xsl:call-template name="punto-debajo">
        <xsl:with-param name="s" select="substring($s, 2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Restituciones y correcciones del editor -->
  <xsl:template match="tei:supplied[@reason='lost']" mode="leiden">
    <xsl:text>[</xsl:text><xsl:apply-templates mode="leiden"/><xsl:text>]</xsl:text>
  </xsl:template>
  <xsl:template match="tei:supplied[@reason='omitted']" mode="leiden">
    <xsl:text>&lt;</xsl:text><xsl:apply-templates mode="leiden"/><xsl:text>&gt;</xsl:text>
  </xsl:template>
  <xsl:template match="tei:supplied" mode="leiden">
    <xsl:apply-templates mode="leiden"/>
  </xsl:template>
  <xsl:template match="tei:surplus" mode="leiden">
    <xsl:text>{</xsl:text><xsl:apply-templates mode="leiden"/><xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:del[@rend='erasure']" mode="leiden">
    <xsl:text>[[</xsl:text><xsl:apply-templates mode="leiden"/><xsl:text>]]</xsl:text>
  </xsl:template>
  <xsl:template match="tei:choice" mode="leiden">
    <xsl:apply-templates select="tei:corr | tei:reg" mode="leiden"/>
  </xsl:template>
  <xsl:template match="tei:corr | tei:reg" mode="leiden">
    <xsl:apply-templates mode="leiden"/>
  </xsl:template>

  <!-- Letras añadidas por el propio autor del grafito -->
  <xsl:template match="tei:add" mode="leiden">
    <span class="add" title="Letra añadida después por el autor del grafito"><xsl:apply-templates mode="leiden"/></span>
  </xsl:template>

  <!-- Lagunas -->
  <xsl:template match="tei:gap" mode="leiden">
    <xsl:variable name="signo">
      <xsl:choose>
        <xsl:when test="@reason='illegible'">+</xsl:when>
        <xsl:otherwise>.</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dentro">
      <xsl:choose>
        <xsl:when test="@quantity and @quantity &lt;= 6">
          <xsl:call-template name="repetir">
            <xsl:with-param name="c" select="$signo"/>
            <xsl:with-param name="n" select="@quantity"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@quantity"><xsl:value-of select="concat($signo, @quantity, $signo)"/></xsl:when>
        <xsl:otherwise>- - -</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@reason='lost'"><xsl:value-of select="concat('[', $dentro, ']')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$dentro"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="repetir">
    <xsl:param name="c"/>
    <xsl:param name="n"/>
    <xsl:if test="$n &gt; 0">
      <xsl:value-of select="$c"/>
      <xsl:call-template name="repetir">
        <xsl:with-param name="c" select="$c"/>
        <xsl:with-param name="n" select="$n - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Signos no alfabéticos: asterisco -->
  <xsl:template match="tei:g[@type='asterisk']" mode="leiden">
    <xsl:text>*</xsl:text>
  </xsl:template>

  <xsl:template match="tei:g[@type='interpunct']" mode="leiden">
    <xsl:text> &#xB7; </xsl:text>
  </xsl:template>

  <xsl:template match="tei:g[@type='swastika']" mode="leiden">
    <xsl:text>&#x5350;</xsl:text>
  </xsl:template>

  <!-- Dibujos y signos no alfabéticos: se muestra su descripción -->
  <xsl:template match="tei:figure" mode="leiden">
    <span class="motivo"><xsl:value-of select="normalize-space(tei:figDesc)"/></span>
  </xsl:template>

  <xsl:template match="tei:space" mode="leiden">
    <xsl:text> </xsl:text><i>vac.</i><xsl:text> </xsl:text>
  </xsl:template>

  <!-- Lecturas alternativas: en el texto principal va la preferida (lem) -->
  <xsl:template match="tei:app" mode="leiden">
    <xsl:apply-templates select="tei:lem" mode="leiden"/>
  </xsl:template>
  <xsl:template match="tei:lem | tei:rdg" mode="leiden">
    <xsl:apply-templates mode="leiden"/>
  </xsl:template>

  <xsl:template match="tei:note" mode="leiden"/>
</xsl:stylesheet>

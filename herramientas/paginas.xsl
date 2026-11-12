<?xml version="1.0" encoding="UTF-8"?>
<!-- Páginas fijas de la web: «Criterios de edición» y «Cómo citar».
     generar-web.ps1 la ejecuta una vez por página, indicando cuál con el parámetro «pagina». -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <xsl:include href="comun.xsl"/>
  <xsl:output method="html" indent="no" encoding="UTF-8"/>
  <xsl:param name="repo"/>
  <xsl:param name="pagina"/>

  <xsl:template match="/">
    <html lang="es">
      <head>
        <xsl:call-template name="head">
          <xsl:with-param name="titulo">
            <xsl:choose>
              <xsl:when test="$pagina = 'citar'">Cómo citar · Grafitos sobre cerámica romana</xsl:when>
              <xsl:otherwise>Criterios de edición · Grafitos sobre cerámica romana</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="descripcion">Grafitos sobre cerámica romana: corpus EpiDoc de Pablo Ozcáriz Gil.</xsl:with-param>
        </xsl:call-template>
      </head>
      <body class="pagina">
        <xsl:call-template name="cabecera">
          <xsl:with-param name="activa" select="$pagina"/>
        </xsl:call-template>
        <main class="estrecho">
          <xsl:choose>
            <xsl:when test="$pagina = 'citar'"><xsl:call-template name="citar"/></xsl:when>
            <xsl:otherwise><xsl:call-template name="criterios"/></xsl:otherwise>
          </xsl:choose>
        </main>
        <xsl:call-template name="pie">
          <xsl:with-param name="repo" select="$repo"/>
        </xsl:call-template>
      </body>
    </html>
  </xsl:template>

  <!-- ===================== Criterios de edición ===================== -->
  <xsl:template name="criterios">
    <h1>Criterios de edición</h1>

    <section>
      <h2>Contenido del corpus</h2>
      <p>El corpus reúne los grafitos sobre cerámica de época romana publicados por Pablo Ozcáriz Gil.
        Solo incluye grafitos: no recoge sellos de alfarero ni <i>tituli picti</i>. Además de los grafitos
        con texto, se editan los grafitos figurativos (dibujos) y los signos.</p>
      <p>Cada grafito tiene una ficha propia, con un identificador formado por el yacimiento, un número
        correlativo y una palabra que lo identifica (por ejemplo, <code>pompelo-029-eutiches</code>).
        Cuando un mismo grafito se ha publicado en varios trabajos, la ficha es única y recoge todas las referencias.</p>
    </section>

    <section>
      <h2>Formato de los datos</h2>
      <p>Las fichas están codificadas en XML según las
        <a href="https://epidoc.stoa.org/">EpiDoc Guidelines</a>, el estándar internacional para la edición
        digital de inscripciones, y se validan con el esquema oficial de EpiDoc. Las páginas de esta web se
        generan automáticamente a partir de esos archivos.</p>
      <p>Cuando el editor propone varias lecturas, la preferida aparece en el texto principal y las demás
        en «Otras lecturas posibles».</p>
    </section>

    <section>
      <h2>Signos del sistema de Leiden</h2>
      <p>La transcripción sigue las convenciones del sistema de Leiden:</p>
      <table class="leiden">
        <thead><tr><th scope="col">Signo</th><th scope="col">Significado</th></tr></thead>
        <tbody>
          <tr><td lang="la">a(bc)</td><td>Abreviatura: el editor desarrolla las letras entre paréntesis.</td></tr>
          <tr><td lang="la">Dom( )</td><td>Abreviatura que no se puede desarrollar con seguridad.</td></tr>
          <tr><td lang="la">[abc]</td><td>Letras perdidas que el editor restituye.</td></tr>
          <tr><td lang="la">[- - -]</td><td>Laguna de extensión desconocida.</td></tr>
          <tr><td lang="la">[...]</td><td>Laguna: cada punto es una letra perdida.</td></tr>
          <tr><td lang="la">ạḅc̣</td><td>Letras dudosas (punto debajo): se ven restos, pero la lectura no es segura.</td></tr>
          <tr><td lang="la">+</td><td>Letra con restos visibles que no se puede identificar.</td></tr>
          <tr><td lang="la">&lt;abc&gt;</td><td>Letras omitidas por quien escribió el grafito, añadidas por el editor.</td></tr>
          <tr><td lang="la">{abc}</td><td>Letras escritas de más, que el editor considera sobrantes.</td></tr>
          <tr><td lang="la">[[abc]]</td><td>Letras borradas en la antigüedad.</td></tr>
          <tr><td lang="la"><span class="add">a</span></td><td>Letra añadida después por el propio autor del grafito (subrayado punteado).</td></tr>
          <tr><td lang="la">·</td><td>Interpunción.</td></tr>
          <tr><td lang="la"><i>vac.</i></td><td>Espacio dejado en blanco intencionadamente.</td></tr>
          <tr><td lang="la">/</td><td>Cambio de línea (en la lista del corpus). En la ficha, cada línea va numerada.</td></tr>
          <tr><td lang="la">(?)</td><td>Lectura o interpretación dudosa.</td></tr>
        </tbody>
      </table>
    </section>
  </xsl:template>

  <!-- ===================== Cómo citar ===================== -->
  <xsl:template name="citar">
    <h1>Cómo citar</h1>

    <section>
      <h2>El corpus completo</h2>
      <p class="cita-texto">
        <xsl:text>Ozcáriz Gil, P., </xsl:text>
        <i><xsl:value-of select="$nombre-corpus"/></i>
        <xsl:text>, </xsl:text><xsl:value-of select="$web"/>
        <xsl:text> (consulta: fecha).</xsl:text>
      </p>
    </section>

    <section>
      <h2>Una ficha concreta</h2>
      <p>Cada ficha tiene una dirección fija que no cambia. Al final de cada ficha hay un recuadro con la cita
        ya preparada y un botón para copiarla. Por ejemplo:</p>
      <p class="cita-texto">
        <xsl:text>Ozcáriz Gil, P., </xsl:text>
        <i><xsl:value-of select="$nombre-corpus"/></i>
        <xsl:text>, ficha pompelo-029-eutiches, </xsl:text>
        <xsl:value-of select="$web"/><xsl:text>pompelo-029-eutiches.html (consulta: fecha).</xsl:text>
      </p>
      <p>Para la edición de cada grafito conviene citar también la publicación original, que aparece en la
        bibliografía de la ficha.</p>
    </section>

    <section>
      <h2>Licencia</h2>
      <p>
        <xsl:text>Los textos y las fichas se publican con licencia </xsl:text>
        <a href="https://creativecommons.org/licenses/by/4.0/deed.es">Creative Commons Atribución 4.0 Internacional (CC BY 4.0)</a>
        <xsl:text>: pueden reutilizarse libremente, también con fines comerciales, siempre que se cite la autoría.</xsl:text>
      </p>
    </section>

    <section>
      <h2>Descarga de los datos</h2>
      <p>
        <xsl:text>Cada ficha puede descargarse en XML EpiDoc desde su página. El conjunto completo de fichas
          y el catálogo en CSV están en el </xsl:text>
        <a href="{$repo}">repositorio de GitHub</a>
        <xsl:text>.</xsl:text>
      </p>
    </section>
  </xsl:template>
</xsl:stylesheet>

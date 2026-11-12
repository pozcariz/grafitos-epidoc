<?xml version="1.0" encoding="UTF-8"?>
<!-- Convierte una ficha EpiDoc en su página web legible -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <xsl:include href="leiden.xsl"/>
  <xsl:output method="xml" omit-xml-declaration="yes" indent="no" encoding="UTF-8"/>

  <!-- Dirección del repositorio en GitHub (la pasa generar-web.ps1) -->
  <xsl:param name="repo"/>

  <xsl:variable name="id" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='filename']"/>
  <xsl:variable name="ms" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc"/>
  <xsl:variable name="body" select="/tei:TEI/tei:text/tei:body"/>

  <xsl:template match="/">
    <html lang="es">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><xsl:value-of select="normalize-space(//tei:titleStmt/tei:title)"/></title>
        <link rel="stylesheet" href="estilo.css"/>
      </head>
      <body>
        <header class="cabecera">
          <a href="index.html">← Corpus de grafitos</a>
        </header>
        <main>
          <p class="id"><xsl:value-of select="$id"/></p>
          <h1><xsl:value-of select="normalize-space(//tei:titleStmt/tei:title)"/></h1>
          <p class="sub">
            <xsl:value-of select="normalize-space($ms/tei:history/tei:origin/tei:origPlace)"/>
            <xsl:text> · </xsl:text>
            <xsl:value-of select="normalize-space($ms/tei:history/tei:origin/tei:origDate)"/>
          </p>

          <xsl:for-each select="/tei:TEI/tei:facsimile//tei:graphic">
            <figure class="foto">
              <img src="{@url}" alt="{normalize-space(tei:desc)}"/>
              <figcaption><xsl:value-of select="normalize-space(tei:desc)"/> Foto: Pablo Ozcáriz Gil.</figcaption>
            </figure>
          </xsl:for-each>

          <section>
            <h2>Texto</h2>
            <div class="edicion" lang="la">
              <xsl:apply-templates select="$body/tei:div[@type='edition']/*" mode="leiden"/>
            </div>
            <xsl:if test="$body/tei:div[@type='edition']//tei:app[@type='alternative']/tei:rdg">
              <p class="alt-titulo">Otras lecturas posibles</p>
              <ul class="alternativas" lang="la">
                <xsl:for-each select="$body/tei:div[@type='edition']//tei:app[@type='alternative']/tei:rdg">
                  <li><xsl:apply-templates select="." mode="leiden"/></li>
                </xsl:for-each>
              </ul>
            </xsl:if>
          </section>

          <xsl:if test="$body/tei:div[@type='apparatus']//tei:note">
            <section>
              <h2>Aparato crítico</h2>
              <xsl:for-each select="$body/tei:div[@type='apparatus']//tei:note">
                <p><xsl:value-of select="normalize-space(.)"/></p>
              </xsl:for-each>
            </section>
          </xsl:if>

          <xsl:if test="$body/tei:div[@type='translation']/tei:p">
            <section>
              <h2>Traducción</h2>
              <xsl:for-each select="$body/tei:div[@type='translation']/tei:p">
                <p><xsl:value-of select="normalize-space(.)"/></p>
              </xsl:for-each>
            </section>
          </xsl:if>

          <xsl:if test="$body/tei:div[@type='commentary']/tei:p">
            <section>
              <h2>Comentario</h2>
              <xsl:for-each select="$body/tei:div[@type='commentary']/tei:p">
                <p><xsl:value-of select="normalize-space(.)"/></p>
              </xsl:for-each>
            </section>
          </xsl:if>

          <section>
            <h2>Descripción</h2>
            <dl class="datos">
              <xsl:call-template name="dato">
                <xsl:with-param name="etiqueta">Soporte</xsl:with-param>
                <xsl:with-param name="valor" select="$ms/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:p"/>
              </xsl:call-template>
              <xsl:if test="$ms//tei:support/tei:dimensions">
                <dt>Dimensiones</dt>
                <dd>
                  <xsl:for-each select="$ms//tei:support/tei:dimensions/*">
                    <xsl:value-of select="translate(., '.', ',')"/>
                    <xsl:if test="position() != last()"> × </xsl:if>
                  </xsl:for-each>
                  <xsl:text> </xsl:text><xsl:value-of select="$ms//tei:support/tei:dimensions/@unit"/>
                  <xsl:text> (alto × ancho × grosor)</xsl:text>
                </dd>
              </xsl:if>
              <xsl:call-template name="dato">
                <xsl:with-param name="etiqueta">Estado</xsl:with-param>
                <xsl:with-param name="valor" select="$ms//tei:supportDesc/tei:condition"/>
              </xsl:call-template>
              <xsl:call-template name="dato">
                <xsl:with-param name="etiqueta">Disposición</xsl:with-param>
                <xsl:with-param name="valor" select="$ms//tei:layoutDesc/tei:layout"/>
              </xsl:call-template>
              <xsl:call-template name="dato">
                <xsl:with-param name="etiqueta">Escritura</xsl:with-param>
                <xsl:with-param name="valor" select="$ms/tei:physDesc/tei:handDesc/tei:handNote"/>
              </xsl:call-template>
              <xsl:call-template name="dato">
                <xsl:with-param name="etiqueta">Datación</xsl:with-param>
                <xsl:with-param name="valor" select="$ms/tei:history/tei:origin/tei:origDate"/>
              </xsl:call-template>
              <xsl:call-template name="dato">
                <xsl:with-param name="etiqueta">Lugar de origen</xsl:with-param>
                <xsl:with-param name="valor" select="$ms/tei:history/tei:origin/tei:origPlace"/>
              </xsl:call-template>
              <xsl:call-template name="dato">
                <xsl:with-param name="etiqueta">Hallazgo</xsl:with-param>
                <xsl:with-param name="valor" select="$ms/tei:history/tei:provenance[@type='found']"/>
              </xsl:call-template>
              <xsl:if test="$ms/tei:msIdentifier/tei:repository">
                <dt>Ubicación actual</dt>
                <dd>
                  <xsl:value-of select="$ms/tei:msIdentifier/tei:repository"/>
                  <xsl:if test="$ms/tei:msIdentifier/tei:settlement">
                    <xsl:text> (</xsl:text><xsl:value-of select="$ms/tei:msIdentifier/tei:settlement"/><xsl:text>)</xsl:text>
                  </xsl:if>
                  <xsl:if test="$ms/tei:msIdentifier/tei:idno[@type='invNo']">
                    <xsl:text>, n.º inv. </xsl:text><xsl:value-of select="$ms/tei:msIdentifier/tei:idno[@type='invNo']"/>
                  </xsl:if>
                </dd>
              </xsl:if>
              <xsl:call-template name="dato">
                <xsl:with-param name="etiqueta">Sigla</xsl:with-param>
                <xsl:with-param name="valor" select="$ms/tei:msIdentifier/tei:altIdentifier/tei:idno"/>
              </xsl:call-template>
            </dl>
          </section>

          <xsl:if test="$body/tei:div[@type='bibliography']//tei:bibl">
            <section>
              <h2>Bibliografía</h2>
              <ul class="biblio">
                <xsl:for-each select="$body/tei:div[@type='bibliography']//tei:bibl">
                  <li>
                    <xsl:value-of select="normalize-space(tei:author)"/>
                    <xsl:text>, «</xsl:text><xsl:value-of select="normalize-space(tei:title[@level='a'])"/><xsl:text>», </xsl:text>
                    <i><xsl:value-of select="normalize-space(tei:title[@level='j' or @level='m'])"/></i>
                    <xsl:if test="tei:biblScope[@unit='volume']"><xsl:text> </xsl:text><xsl:value-of select="tei:biblScope[@unit='volume']"/></xsl:if>
                    <xsl:if test="tei:date"><xsl:text> (</xsl:text><xsl:value-of select="tei:date"/><xsl:text>)</xsl:text></xsl:if>
                    <xsl:if test="tei:biblScope[@unit='page']"><xsl:text>, pp. </xsl:text><xsl:value-of select="tei:biblScope[@unit='page']"/></xsl:if>
                    <xsl:text>.</xsl:text>
                  </li>
                </xsl:for-each>
              </ul>
            </section>
          </xsl:if>
        </main>

        <footer class="pie">
          <p>
            <a href="{$repo}/blob/main/epidoc/{$id}.xml">Ver la ficha en XML EpiDoc</a>
            <xsl:text> · </xsl:text>
            <a href="{$repo}">Repositorio en GitHub</a>
          </p>
          <p>
            <xsl:text>Publicado con licencia </xsl:text>
            <a href="https://creativecommons.org/licenses/by/4.0/deed.es">CC BY 4.0</a>
            <xsl:text>. Cómo citar: Ozcáriz Gil, P., </xsl:text>
            <i>Grafitos sobre cerámica romana: corpus EpiDoc</i>
            <xsl:text>, ficha </xsl:text><xsl:value-of select="$id"/><xsl:text>.</xsl:text>
          </p>
        </footer>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="dato">
    <xsl:param name="etiqueta"/>
    <xsl:param name="valor"/>
    <xsl:if test="normalize-space($valor) != ''">
      <dt><xsl:value-of select="$etiqueta"/></dt>
      <dd><xsl:value-of select="normalize-space($valor)"/></dd>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>

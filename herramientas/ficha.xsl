<?xml version="1.0" encoding="UTF-8"?>
<!-- Convierte una ficha EpiDoc en su página web legible -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <xsl:include href="leiden.xsl"/>
  <xsl:include href="comun.xsl"/>
  <xsl:output method="html" indent="no" encoding="UTF-8"/>

  <!-- Dirección del repositorio en GitHub (la pasa generar-web.ps1) -->
  <xsl:param name="repo"/>
  <!-- Corpus completo (lo pasa generar-web.ps1), para enlazar con los grafitos del mismo yacimiento -->
  <xsl:param name="corpus"/>

  <xsl:variable name="id" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='filename']"/>
  <xsl:variable name="ms" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc"/>
  <xsl:variable name="body" select="/tei:TEI/tei:text/tei:body"/>
  <xsl:variable name="titulo" select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/>
  <xsl:variable name="yac" select="normalize-space($ms/tei:history/tei:origin/tei:origPlace/tei:placeName[@type='ancient'])"/>
  <xsl:variable name="hermanos" select="$corpus/corpus/entrada[@yac = $yac]"/>

  <xsl:template match="/">
    <html lang="es">
      <head>
        <xsl:call-template name="head">
          <xsl:with-param name="titulo"><xsl:value-of select="$titulo"/></xsl:with-param>
          <xsl:with-param name="descripcion"><xsl:value-of select="$titulo"/>. Edición EpiDoc.</xsl:with-param>
        </xsl:call-template>
        <link rel="alternate" type="application/tei+xml" href="xml/{$id}.xml"/>
      </head>
      <body class="ficha">
        <xsl:call-template name="cabecera"/>

        <main class="ancho">
          <nav class="migas" aria-label="Estás en">
            <a href="index.html#corpus">Corpus</a>
            <xsl:if test="$yac != ''">
              <xsl:text> › </xsl:text>
              <a href="index.html?yac={$yac}#corpus"><xsl:value-of select="$yac"/></a>
            </xsl:if>
            <xsl:text> › </xsl:text>
            <span aria-current="page"><xsl:value-of select="$id"/></span>
          </nav>

          <h1><xsl:value-of select="$titulo"/></h1>
          <p class="sub">
            <xsl:value-of select="normalize-space($ms/tei:history/tei:origin/tei:origPlace)"/>
            <xsl:if test="normalize-space($ms/tei:history/tei:origin/tei:origDate) != ''">
              <xsl:text> · </xsl:text>
              <xsl:value-of select="normalize-space($ms/tei:history/tei:origin/tei:origDate)"/>
            </xsl:if>
          </p>

          <div class="principal">
            <xsl:attribute name="class">
              <xsl:text>principal</xsl:text>
              <xsl:if test="not(/tei:TEI/tei:facsimile//tei:graphic)"> sin-foto</xsl:if>
            </xsl:attribute>
            <xsl:if test="/tei:TEI/tei:facsimile//tei:graphic">
              <div class="fotos">
                <xsl:for-each select="/tei:TEI/tei:facsimile//tei:graphic">
                  <figure class="foto">
                    <a href="{@url}" title="Ver la foto a tamaño completo">
                      <img src="{@url}" alt="{normalize-space(tei:desc)}" loading="lazy"/>
                    </a>
                    <figcaption><xsl:value-of select="normalize-space(tei:desc)"/> Foto: Pablo Ozcáriz Gil.</figcaption>
                  </figure>
                </xsl:for-each>
              </div>
            </xsl:if>

            <section class="texto">
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
              <p class="ayuda-leiden"><a href="criterios.html">¿Qué significan los signos?</a></p>
            </section>
          </div>

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
                <xsl:with-param name="etiqueta">Descripción del grafito</xsl:with-param>
                <xsl:with-param name="valor" select="$ms/tei:physDesc/tei:decoDesc/tei:decoNote"/>
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

          <section class="citar">
            <h2>Cómo citar esta ficha</h2>
            <p id="cita" class="cita-texto">
              <xsl:text>Ozcáriz Gil, P., </xsl:text>
              <i><xsl:value-of select="$nombre-corpus"/></i>
              <xsl:text>, ficha </xsl:text><xsl:value-of select="$id"/><xsl:text>, </xsl:text>
              <xsl:value-of select="concat($web, $id, '.html')"/>
              <span id="cita-fecha"></span>
              <xsl:text>.</xsl:text>
            </p>
            <div class="acciones">
              <button type="button" id="copiar-cita" hidden="hidden">Copiar cita</button>
              <a class="boton" href="xml/{$id}.xml" download="{$id}.xml">Descargar XML EpiDoc</a>
              <a class="boton" href="{$repo}/blob/main/epidoc/{$id}.xml">Ver en GitHub</a>
              <button type="button" id="imprimir" hidden="hidden">Imprimir</button>
            </div>
          </section>

          <xsl:if test="count($hermanos) &gt; 1">
            <nav class="vecinos" aria-label="Otros grafitos del yacimiento">
              <xsl:for-each select="$hermanos">
                <xsl:sort select="@id"/>
                <xsl:if test="@id = $id">
                  <xsl:variable name="pos" select="position()"/>
                  <xsl:variable name="ordenados-ant">
                    <xsl:for-each select="$hermanos">
                      <xsl:sort select="@id"/>
                      <xsl:if test="position() = $pos - 1"><xsl:value-of select="@id"/></xsl:if>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:variable name="ordenados-sig">
                    <xsl:for-each select="$hermanos">
                      <xsl:sort select="@id"/>
                      <xsl:if test="position() = $pos + 1"><xsl:value-of select="@id"/></xsl:if>
                    </xsl:for-each>
                  </xsl:variable>
                  <span class="vecino-ant">
                    <xsl:if test="$ordenados-ant != ''">
                      <a href="{$ordenados-ant}.html" rel="prev">← <xsl:value-of select="$ordenados-ant"/></a>
                    </xsl:if>
                  </span>
                  <a class="vecino-todos" href="index.html?yac={$yac}#corpus">
                    <xsl:text>Los </xsl:text><xsl:value-of select="count($hermanos)"/>
                    <xsl:text> grafitos de </xsl:text><xsl:value-of select="$yac"/>
                  </a>
                  <span class="vecino-sig">
                    <xsl:if test="$ordenados-sig != ''">
                      <a href="{$ordenados-sig}.html" rel="next"><xsl:value-of select="$ordenados-sig"/> →</a>
                    </xsl:if>
                  </span>
                </xsl:if>
              </xsl:for-each>
            </nav>
          </xsl:if>
        </main>

        <xsl:call-template name="pie">
          <xsl:with-param name="repo" select="$repo"/>
        </xsl:call-template>
        <script src="web.js"></script>
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

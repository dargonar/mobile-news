<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:news="http://www.diariosmoviles.com.ar/news-rss/">
  
  <xsl:include href="functions.xsl" />
  <xsl:output method="html" 
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="yes" encoding="UTF-8"/>
  
  <xsl:template match="/">
    <html>
      <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      <title>clasificados</title>
      <link rel="stylesheet" href="css/layout_tablet.css" type="text/css" />
      </head>

      <body>

        <div id="clasificados">
          <div class="columna">
            <div class="encabezado">
              <div class="titulo">Clasificados</div>
              <div class="rubro"><xsl:value-of select="rss/channel/item[1]/title"/></div>

              <p></p> <!-- Seleccionar otra fecha -->
              <div class="calendario">
                <xsl:call-template name="ParseDate">
                  <xsl:with-param name="DateTime" select="rss/channel/pubDate"/>
                  <xsl:with-param name="DatePart" select="'day'"/>
                </xsl:call-template>
              </div>
              <div class="calendario">
                <xsl:call-template name="ParseDate">
                  <xsl:with-param name="DateTime" select="rss/channel/pubDate"/>
                  <xsl:with-param name="DatePart" select="'month'"/>
                </xsl:call-template>
              </div>
              <div class="calendario">
                <xsl:call-template name="ParseDate">
                  <xsl:with-param name="DateTime" select="rss/channel/pubDate"/>
                  <xsl:with-param name="DatePart" select="'year'"/>
                </xsl:call-template>
              </div>
              <div class="clear"></div>
            </div><!-- encabezado -->

            <xsl:call-template name="clasificados_primer_columna">
              <xsl:with-param name="Nodes" select="rss/channel/item"/>
            </xsl:call-template>
          </div><!-- columna -->

          <div class="columna">
            <xsl:call-template name="clasificados_segunda_columna">
              <xsl:with-param name="Nodes" select="rss/channel/item"/>
            </xsl:call-template>
          </div><!-- columna -->

          <div class="columna">
            <xsl:call-template name="clasificados_tercer_columna">
              <xsl:with-param name="Nodes" select="rss/channel/item"/>
            </xsl:call-template>
          </div><!-- columna -->
        </div><!-- clasificados -->
      </body>
    </html>
  </xsl:template>
  
  <xsl:template name="clasificados_tercer_columna">
  <xsl:param name="Nodes" />
    <xsl:for-each select="$Nodes">
      <xsl:if test="(position() mod 3)=0 and position() &lt; count($Nodes)">
        <xsl:call-template name="aviso_clasificado">
          <xsl:with-param name="Node" select="."/>
        </xsl:call-template>
      </xsl:if>
      </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="clasificados_segunda_columna">
  <xsl:param name="Nodes" />
    <xsl:for-each select="$Nodes">
      <xsl:if test="(position() mod 3)=2 and position() &lt; count($Nodes)">
        <xsl:call-template name="aviso_clasificado">
          <xsl:with-param name="Node" select="."/>
        </xsl:call-template>
      </xsl:if>
      </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="clasificados_primer_columna">
  <xsl:param name="Nodes" />
    <xsl:for-each select="$Nodes">
      <xsl:if test="(position() mod 3)=1 and position() &lt; count($Nodes)">
        <xsl:call-template name="aviso_clasificado">
          <xsl:with-param name="Node" select="."/>
        </xsl:call-template>
      </xsl:if>
      </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="aviso_clasificado">
    <xsl:param name="Node" />
    <div class="aviso">
      <!-- label class="fecha">
        <xsl:call-template name="FormatDate">
          <xsl:with-param name="DateTime" select="$Node/pubDate"/>
        </xsl:call-template>
      </label --> <!--| <label class="hora">18:45</label>-->
      <p><xsl:value-of disable-output-escaping="yes" select="$Node/description" /></p>
    </div><!-- aviso -->  
  </xsl:template>
</xsl:stylesheet>
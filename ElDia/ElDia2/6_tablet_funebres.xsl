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
        <title>FUNEBRES</title>
        <link rel="stylesheet" href="css/layout_tablet.css" type="text/css" />
        <!-- meta name="viewport" content="width=960;user-scalable=no;" / -->
        <meta name="viewport" content="width=device-width; minimum-scale=0.5; maximum-scale=0.8; user-scalable=no;');" />

      </head>
      
      <body>
        
        <div id="clasificados">
          <div class="columna">
            <div class="encabezado">
              <div class="titulo">Fúnebres</div>
              
              <p></p> <!-- Seleccionar otra fecha -->
              <div class="clear"></div>
            </div><!-- encabezado -->
            
            <xsl:call-template name="clasificados_columna">
              <xsl:with-param name="Nodes" select="rss/channel/item"/>
              <xsl:with-param name="From" select="1"/>
              <xsl:with-param name="To" select="round(count(rss/channel/item) div 3)"/>
            </xsl:call-template>
          </div><!-- columna -->
          
          <div class="columna">
            <xsl:call-template name="clasificados_columna">
              <xsl:with-param name="Nodes" select="rss/channel/item"/>
              <xsl:with-param name="From" select="round(count(rss/channel/item) div 3)"/>
              <xsl:with-param name="To" select="round(count(rss/channel/item) div 3)*2"/>
            </xsl:call-template>
          </div><!-- columna -->
          
          <div class="columna">
            <xsl:call-template name="clasificados_columna">
              <xsl:with-param name="Nodes" select="rss/channel/item"/>
              <xsl:with-param name="From" select="round(count(rss/channel/item) div 3)*2"/>
              <xsl:with-param name="To" select="count(rss/channel/item)"/>
            </xsl:call-template>
          </div><!-- columna -->
        </div><!-- clasificados -->
      </body>
    </html>
  </xsl:template>
  
  <xsl:template name="clasificados_columna">
    <xsl:param name="Nodes" />
    <xsl:param name="From" />
    <xsl:param name="To" />
    <xsl:for-each select="$Nodes">
      <xsl:if test="(position() &gt;= $From) and position() &lt; $To">
        <xsl:call-template name="aviso_clasificado">
          <xsl:with-param name="Node" select="."/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="aviso_clasificado">
    <xsl:param name="Node" />
    <xsl:if test="position() != last()">
      <xsl:if test="position()=1 or preceding-sibling::item[1]/category != ./category">
        <div class="rubro">
          <xsl:value-of disable-output-escaping="yes" select="normalize-space(./category)" />
        </div>
      </xsl:if>
      <div class="aviso fune">
        <p><xsl:value-of disable-output-escaping="yes" select="$Node/description" /></p>
      </div>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
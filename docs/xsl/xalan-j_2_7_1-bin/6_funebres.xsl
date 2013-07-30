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
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <meta name="viewport" content="width=320;user-scalable=no;" />
        <link rel="stylesheet" type="text/css" href="css/layout.css" />
        <title>FUNEBRES</title>
      </head>
      <body>

        <div id="clasificados">
          <div class="columna">
            <div class="encabezado">
              <div class="titulo">Funebres</div>
              <p></p>
              <div class="clear"></div>
            </div>
            
            <xsl:for-each select="rss/channel/item">
              <xsl:variable name="pos" select="position()-1" />
                <xsl:if test="position() != last()">
                <xsl:if test="position()=1 or preceding-sibling::item[1]/category != ./category">
                  <div class="rubro">
                    <xsl:value-of disable-output-escaping="yes" select="normalize-space(./category)" />
                  </div>
                </xsl:if>
                <div class="aviso"> <p> <xsl:value-of disable-output-escaping="yes" select="description" /> </p> </div>
              </xsl:if>
            </xsl:for-each>
          </div>  
        </div>
              </body>
    </html>
  </xsl:template>
  
</xsl:stylesheet>
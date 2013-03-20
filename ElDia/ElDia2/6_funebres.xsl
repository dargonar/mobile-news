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
        <!-- link rel="stylesheet" type="text/css" media="only screen and (max-device-width: 480px)" href="css/layout.css" / -->
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
              <!-- 
              before-pos:<xsl:value-of disable-output-escaping="yes" select="$pos" /> <br />
              sorto:<xsl:value-of disable-output-escaping="yes" select="preceding-sibling::item[1]/category"/> <br />
              preceding-sibling:<xsl:value-of disable-output-escaping="yes" select="preceding-sibling::*/category" /> <br />
              before:<xsl:value-of disable-output-escaping="yes" select="rss/channel/item[$pos]" /> <br />
              current:<xsl:value-of disable-output-escaping="yes" select="./category" />
              -->
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
        
        <!--div id="clasificados">
          <div class="menu-header">
            <xsl:value-of disable-output-escaping="yes" select="rss/channel/item[1]/title" />
          </div>
          <ul id="clasificados_container">
            <xsl:for-each select="rss/channel/item">
              <li> <div> <xsl:value-of disable-output-escaping="yes" select="description" /> </div> </li>
            </xsl:for-each>
          </ul>
        </div-->
        
      </body>
    </html>
  </xsl:template>
  
</xsl:stylesheet>
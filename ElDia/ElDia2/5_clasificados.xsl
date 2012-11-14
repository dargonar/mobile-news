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
        <!-- meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no, width=device-width" / -->
        <link rel="stylesheet" type="text/css" href="css/layout.css" />
        <!-- link rel="stylesheet" type="text/css" media="only screen and (max-device-width: 480px)" href="css/layout.css" / -->
        <title>CLASIFICADOS</title>
      </head>
      
      <body>
        <div id="clasificados">
          <div class="menu-header">
            <xsl:value-of disable-output-escaping="yes" select="rss/channel/item[1]/title" />
          </div>
          <ul id="clasificados_container">
            <xsl:for-each select="rss/channel/item">
              <li> <div> <xsl:value-of disable-output-escaping="yes" select="description" /> </div> </li>
            </xsl:for-each>
          </ul>
        </div>
        
      </body>
    </html>
  </xsl:template>
  
</xsl:stylesheet>
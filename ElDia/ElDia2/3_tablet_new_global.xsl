<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:news="http://www.diariosmoviles.com.ar/news-rss/">
  
  <!-- 
    lead
    http://www.eldia.com.ar/rss/noticia.aspx?id=0_395036 con foto
    http://www.eldia.com.ar/rss/noticia.aspx?id=1_163405 no foto
  -->
  <xsl:include href="functions.xsl" />
  <!--xsl:output method="html" encoding="UTF-8" indent="yes"/-->
  <xsl:output method="html" 
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="yes" encoding="UTF-8"/>
 
  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <link rel="stylesheet" type="text/css" href="css/layout_tablet.css" />
        <title>NOTICIA global</title>
        <meta name="viewport" content="width=device-width,user-scalable=no" />
        <script type="text/javascript" src="js/functions.js"></script>
      </head>
      
      <body onload="update_imagen_nota_abierta()" class="portrait padded global">
        
          <xsl:call-template name="tablet_open_new_global">
            <xsl:with-param name="Node" select="rss/channel/item[1]"/>
          </xsl:call-template>
         
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
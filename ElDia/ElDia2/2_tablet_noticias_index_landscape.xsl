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
        <!--meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no, width=device-width" /-->
        <!-- meta name="viewport" content="width=600;user-scalable=no;" / -->
        <meta name="viewport" content="width=device-width; minimum-scale=0.5; maximum-scale=1.0; user-scalable=no;" />
        <link rel="stylesheet" type="text/css" href="css/layout_tablet.css" />
        <!-- link rel="stylesheet" type="text/css" media="only screen and (max-device-width: 480px)" href="css/layout_tablet.css" / -->
        <title>NOTICIAS DE SECCION</title>
        <script type="text/javascript" src="js/functions.js"></script>
      </head>
      
      <body class="menu landscape" onload="update_all_images()">
        <div id="landscape">
          <div class="seccion list">Principal</div>
          <div class="menu">
            <ul class="landscape_news_list">
                <xsl:call-template name="tablet_news_list_landscape">
                  <xsl:with-param name="Nodes" select="rss/channel/item"/>
                </xsl:call-template>
              </ul>
            </div><!-- menu -->
        </div><!-- landscape -->
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
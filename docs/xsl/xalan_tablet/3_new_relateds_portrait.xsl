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
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no, width=device-width" />
        <link rel="stylesheet" type="text/css" href="css/layout_tablet.css" />
        <!-- link rel="stylesheet" type="text/css" media="only screen and (max-device-width: 480px)" href="css/layout_tablet.css" / -->
        <title>NOTICIAS RELACIONADAS PORTRAIT</title>
        <script type="text/javascript" src="js/functions.js"></script>
      </head>
      
      <body class="menu portrait" onload="update_all_images()">
        
        <xsl:if test="rss/channel/item[1]/news:related" >
          <xsl:call-template name="tablet_news_related_portrait">
            <xsl:with-param name="Items" select="rss/channel/item[1]/news:related"/>
          </xsl:call-template>
        </xsl:if>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
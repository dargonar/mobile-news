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
        <link rel="stylesheet" type="text/css" href="css/layout_tablet.css" />
        <title>LISTADO PRINCIPAL</title>
        <meta name="viewport" content="width=device-width,user-scalable=no" />
        <script type="text/javascript" src="js/functions.js"></script>
      </head>
      
      <body onload="update_all_images()" class="portrait padded">
        <div id="updated_msg" class="updated hidden">Actualizado hace 1 segundo</div>
        <div id="index" class="padded_landscape">
          
          <xsl:if test="not(rss/channel/item[1]/media:thumbnail)" >
            <xsl:call-template name="tablet_index_portrait_secondary">
              <xsl:with-param name="Nodes" select="rss/channel/item[position() &gt; 0 and position() &lt; 3]"/>
            </xsl:call-template>
            
            <xsl:call-template name="tablet_index_portrait_terciary">
              <xsl:with-param name="Nodes" select="rss/channel/item[position() &gt; 2]"/>
            </xsl:call-template>
          </xsl:if>
          
          <xsl:if test="not(not(rss/channel/item[1]/media:thumbnail))" >
            <xsl:call-template name="tablet_index_portrait_main">
              <xsl:with-param name="Node" select="rss/channel/item[1]"/>
            </xsl:call-template>
            
            <xsl:call-template name="tablet_index_portrait_secondary">
              <xsl:with-param name="Nodes" select="rss/channel/item[position() &gt; 1 and position() &lt; 4]"/>
            </xsl:call-template>
            
            <xsl:call-template name="tablet_index_portrait_terciary">
              <xsl:with-param name="Nodes" select="rss/channel/item[position() &gt; 3]"/>
            </xsl:call-template>
          </xsl:if>
        </div>
      </body>
    </html>
  </xsl:template>
  
</xsl:stylesheet>
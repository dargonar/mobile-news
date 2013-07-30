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
        <link rel="stylesheet" type="text/css" href="css/layout.css" />
        <meta name="viewport" content="width=320;user-scalable=no;" /> <!-- HACK: NO ESTABA -->
        <title>SECCIONES</title>
        <script type="text/javascript" src="js/functions.js"></script>
      </head>
      
      <body>
        <div id="updated_msg" class="updated hidden">Actualizado hace 10 minutos</div>
        <xsl:call-template name="TituloSeccionONotisRelac">
          <xsl:with-param name="Titulo" select="rss/channel/item[1]/category"/>
        </xsl:call-template>
        
        <xsl:call-template name="ListadoNoticiasEnListado">
          <xsl:with-param name="Nodes" select="rss/channel/item"/>
        </xsl:call-template>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
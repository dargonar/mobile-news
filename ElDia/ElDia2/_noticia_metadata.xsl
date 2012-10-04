<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:news="http://www.diariosmoviles.com.ar/news-rss/">
  
  <xsl:output method="text" indent="yes" encoding="UTF-8"/>
  
  <xsl:template match="/">
    <xsl:value-of select="rss/channel/item[1]/link"/>
  </xsl:template>

</xsl:stylesheet>